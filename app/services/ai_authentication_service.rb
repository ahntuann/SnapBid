require "base64"
require "json"

class AiAuthenticationService
  def self.verify_listing!(listing)
    listing.update!(status: :submitted_for_ai)

    # Nếu không có túi mẫu thì fallback về logic cũ hoặc báo lỗi tuỳ bạn
    # Ở đây mình giả sử user đã chọn Reference Item rồi
    result = call_openai_vision!(listing)

    mapped_status = map_status(result[:status], result[:confidence])
    listing.update!(status: mapped_status, ai_note: result[:reason])
  rescue => e
    listing.update!(status: :manual_review, ai_note: "Lỗi AI: #{e.message}")
    raise
  end

  def self.map_status(raw_status, confidence)
    case raw_status.to_s.downcase
    when "verified"
      confidence >= 0.7 ? :verified : :manual_review
    when "rejected"
      :rejected
    else
      :manual_review
    end
  end

  def self.call_openai_vision!(listing)
    api_key = ENV.fetch("OPENAI_API_KEY")
    
    # 1. Lấy ảnh người dùng upload (User Images)
    user_images = prepare_images(listing.images.first(5))

    # 2. Lấy ảnh mẫu chuẩn Auth từ DB (Reference Images)
    # Nếu listing chưa chọn reference_item thì mảng này rỗng
    ref_images = listing.reference_item ? prepare_images(listing.reference_item.images.first(5)) : []

    # Xây dựng Prompt chặt chẽ hơn
    prompt = <<~PROMPT
      Bạn là chuyên gia thẩm định túi xách cao cấp (Authenticator).
      Nhiệm vụ: So sánh "ẢNH NGƯỜI DÙNG" với "ẢNH MẪU CHUẨN (REFERENCE)" và mô tả để xác thực.
      
      Thông tin sản phẩm: #{listing.reference_item&.name || listing.title}
      Mô tả của người bán: "#{listing.seller_note}"

      Hãy thực hiện 2 bước kiểm tra:
      1. SO SÁNH HÌNH ẢNH: Các ảnh của người dùng có khớp hoàn toàn về kiểu dáng, chi tiết, logo, đường may so với ảnh mẫu chuẩn không? Có dấu hiệu hàng fake không?
      2. KIỂM TRA MÔ TẢ: Ảnh người dùng có khớp với tình trạng người bán mô tả không?

      Lưu ý: 
      - 5 ảnh đầu tiên tôi gửi là ẢNH MẪU CHUẨN (AUTHENTIC).
      - Các ảnh tiếp theo là ẢNH NGƯỜI DÙNG CẦN CHECK.
      
      Trả về JSON duy nhất (không markdown):
      {
        "status": "verified" | "rejected" | "uncertain",
        "confidence": 0.0-1.0,
        "reason": "Giải thích chi tiết bằng tiếng Việt: Tại sao giống/khác mẫu? Tại sao khớp/không khớp mô tả?"
      }
    PROMPT

    # Gộp ảnh: Ảnh mẫu trước -> Ảnh user sau
    all_images_payload = ref_images + user_images

    conn = Faraday.new(url: "https://api.openai.com") do |f|
      f.request :json
      f.response :json
      f.options.timeout = 120 # Tăng timeout vì gửi nhiều ảnh
    end

    resp = conn.post("/v1/chat/completions") do |req|
      req.headers["Authorization"] = "Bearer #{api_key}"
      req.headers["Content-Type"] = "application/json"
      req.body = {
        model: "gpt-4o-mini", # Hoặc gpt-4o nếu bạn giàu (tốt hơn nhiều cho soi ảnh)
        messages: [
          { role: "system", content: "Chỉ trả về JSON hợp lệ." },
          { role: "user", content: [{ type: "input_text", text: prompt }, *all_images_payload] }
        ],
        temperature: 0.1
      }
    end

    parse_response(resp)
  end

  # Hàm phụ để biến đổi ảnh thành base64 gửi cho OpenAI
  def self.prepare_images(attachments)
    # Vì input đầu vào là Array (do lệnh .first(5)), nên ta kiểm tra rỗng bằng .empty?
    return [] if attachments.blank? 
    
    attachments.map do |img|
      begin
        # Tải ảnh về RAM -> Convert Base64
        bytes = img.download 
        b64 = Base64.strict_encode64(bytes)
        { 
          type: "image_url", 
          image_url: { url: "data:image/jpeg;base64,#{b64}" } 
        }
      rescue => e
        # Bỏ qua nếu ảnh lỗi
        nil
      end
    end.compact # Loại bỏ các phần tử nil nếu có lỗi
  end

  def self.parse_response(resp)
    # 1. IN RA TERMINAL ĐỂ DEBUG (Xem tab chạy rails s)
    puts "========== DEBUG OPENAI RESPONSE =========="
    puts "Status: #{resp.status}"
    puts "Body: #{resp.body}"
    puts "==========================================="

    # Kiểm tra nếu API lỗi (401, 500...)
    unless resp.success?
      return {
        status: :uncertain,
        confidence: 0.0,
        reason: "Lỗi gọi API: #{resp.status} - #{resp.body.to_s[0..100]}...",
        raw: resp.body
      }
    end

    content = resp.body.dig("choices", 0, "message", "content").to_s

    # 2. LÀM SẠCH JSON (Tìm đoạn bắt đầu bằng { và kết thúc bằng })
    # OpenAI hay trả về kiểu: ```json { ... } ``` nên phải cắt bỏ rác
    json_match = content.match(/\{.*\}/m)
    clean_content = json_match ? json_match[0] : content

    begin
      parsed = JSON.parse(clean_content)
      {
        status: (parsed["status"] || "uncertain"),
        confidence: (parsed["confidence"] || 0.0).to_f,
        reason: (parsed["reason"] || "AI không đưa ra lý do"),
        raw: resp.body
      }
    rescue JSON::ParserError
      # Trường hợp AI trả về text thường chứ không phải JSON
      {
        status: :manual_review,
        confidence: 0.0,
        reason: "AI trả về định dạng sai: #{content[0..100]}...",
        raw: resp.body
      }
    end
  end
end