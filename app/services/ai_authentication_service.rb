require 'net/http'
require 'uri'
require 'json'

class AiAuthenticationService
  def self.verify_listing!(listing)
    # 1. CHECK ẢNH USER
    unless listing.images.attached?
      listing.update!(status: :rejected, ai_note: "AI Từ chối: Không tìm thấy ảnh sản phẩm.")
      return
    end

    # 2. CHECK ẢNH MẪU
    reference = listing.reference_item
    unless reference && reference.images.attached?
      listing.update!(status: :manual_review, ai_note: "Hệ thống thiếu dữ liệu mẫu. Chờ duyệt tay.")
      return
    end

    listing.update!(status: :submitted_for_ai)
    api_key = ENV['OPENAI_API_KEY']
    return if api_key.blank?

    # --- HÀM TỐI ƯU URL (VŨ KHÍ BÍ MẬT) ---
    # Chèn tham số resize vào URL của Cloudinary để ảnh nhẹ đi
    def self.optimize_cloudinary_url(attachment)
      original_url = attachment.url
      # Tìm đoạn "/upload/" và chèn thêm tham số nén (rộng tối đa 800px, chất lượng tự động)
      # Kết quả: .../upload/w_800,q_auto,f_auto/...
      original_url.sub("/upload/", "/upload/w_800,q_auto,f_auto/")
    rescue
      attachment.url # Fallback nếu lỗi
    end
    # --------------------------------------

    # 3. LẤY URL ĐÃ ĐƯỢC NÉN (OPTIMIZED)
    ref_urls = reference.images.first(5).map { |img| optimize_cloudinary_url(img) }
    user_urls = listing.images.first(5).map { |img| optimize_cloudinary_url(img) }

    # 4. CHUẨN BỊ NỘI DUNG GỬI AI
    messages_content = []

    # System Prompt
    prompt_text = <<~TEXT
      Bạn là Chuyên gia Thẩm định Hàng hiệu (Professional Authenticator).
      Sản phẩm: "#{listing.title}".
      Mô tả người bán: "#{listing.seller_note}".

      Nhiệm vụ:
      1. SO SÁNH 'ẢNH MẪU CHUẨN' và 'ẢNH CẦN CHECK'.
      2. KIỂM TRA MÔ TẢ tình trạng sản phẩm.

      Yêu cầu trả về JSON (Tiếng Việt):
      {
        "result": "AUTHENTIC" | "FAKE" | "UNCERTAIN",
        "confidence": (0-100),
        "reason": "Nhận xét ngắn gọn dưới 50 từ về độ giống/khác mẫu và tình trạng thực tế."
      }
    TEXT

    messages_content << { type: "text", text: prompt_text }

    # Gửi ảnh mẫu
    messages_content << { type: "text", text: "--- ẢNH MẪU CHUẨN (REFERENCE) ---" }
    ref_urls.each { |url| messages_content << { type: "image_url", image_url: { url: url } } }

    # Gửi ảnh User
    messages_content << { type: "text", text: "--- ẢNH SẢN PHẨM CẦN CHECK ---" }
    user_urls.each { |url| messages_content << { type: "image_url", image_url: { url: url } } }

    # 5. GỬI REQUEST
    uri = URI("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120 # Timeout 2 phút

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{api_key}"

    request.body = {
      model: "gpt-4o",
      messages: [{ role: "user", content: messages_content }],
      max_tokens: 500,
      temperature: 0.2,
      response_format: { type: "json_object" }
    }.to_json

    begin
      response = http.request(request)
      if response.code == "200"
        body = JSON.parse(response.body)
        parsed = JSON.parse(body.dig("choices", 0, "message", "content"))
        
        new_status = case parsed["result"]
                     when "AUTHENTIC" then (parsed["confidence"].to_i >= 80 ? :verified : :manual_review)
                     when "FAKE" then :rejected
                     else :manual_review
                     end
        
        listing.update!(status: new_status, ai_note: "Độ tin cậy: #{parsed['confidence']}%. #{parsed['reason']}")
      else
        error_msg = JSON.parse(response.body).dig("error", "message") rescue response.body
        listing.update!(status: :manual_review, ai_note: "Lỗi kết nối AI: #{error_msg}")
      end
    rescue => e
      listing.update!(status: :manual_review, ai_note: "Lỗi xử lý: #{e.message}")
    end
  end
end