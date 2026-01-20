require 'net/http'
require 'uri'
require 'json'

class AiAuthenticationService
  def self.verify_listing!(listing)
    # 1. CHECK ẢNH USER
    unless listing.images.attached?
      listing.update!(status: :rejected, ai_note: "AI Từ chối: Không tìm thấy ảnh sản phẩm để kiểm tra.")
      return
    end

    # 2. CHECK ẢNH MẪU (REFERENCE)
    reference = listing.reference_item
    unless reference && reference.images.attached?
      listing.update!(status: :manual_review, ai_note: "Hệ thống thiếu dữ liệu mẫu để so sánh. Vui lòng chờ nhân viên duyệt.")
      return
    end

    listing.update!(status: :submitted_for_ai)
    api_key = ENV['OPENAI_API_KEY']
    return if api_key.blank?

    # 3. LẤY URL ẢNH (Admin đã update ảnh lên Cloudinary rồi nhé)
    ref_urls = reference.images.first(5).map(&:url)
    user_urls = listing.images.first(5).map(&:url)

    # 4. CHUẨN BỊ NỘI DUNG GỬI AI (PROMPT NÂNG CẤP)
    messages_content = []

    # --- PHẦN CHỈ ĐẠO AI (SYSTEM PROMPT) ---
    prompt_text = <<~TEXT
      Bạn là một Chuyên gia Thẩm định Hàng hiệu (Professional Authenticator) uy tín.
      Nhiệm vụ của bạn là kiểm tra sản phẩm "#{listing.title}" dựa trên hình ảnh được cung cấp.

      Dữ liệu đầu vào:
      1. ẢNH MẪU CHUẨN (Reference): Đây là ảnh gốc của hãng, dùng làm tiêu chuẩn Authentic.
      2. ẢNH SẢN PHẨM CẦN CHECK (User Upload): Ảnh thực tế do người bán chụp.
      3. MÔ TẢ CỦA NGƯỜI BÁN: "#{listing.seller_note}" (Ví dụ: Mới 99%, có vết xước nhỏ, mất phụ kiện...)

      Hãy thực hiện 2 bước đánh giá và trả về kết quả JSON (Tuyệt đối không dùng từ 'Nhóm 1', 'Nhóm 2'):

      BƯỚC 1: SO SÁNH AUTH/FAKE
      - So sánh chi tiết (logo, đường may, font chữ, form dáng) của 'ẢNH CẦN CHECK' so với 'ẢNH MẪU CHUẨN'.
      - Nếu giống hệt hoặc chỉ khác biệt do ánh sáng/góc chụp -> AUTHENTIC.
      - Nếu sai lệch logo, form dáng, chi tiết quan trọng -> FAKE.
      - Nếu ảnh quá mờ, không rõ chi tiết -> UNCERTAIN.

      BƯỚC 2: KIỂM TRA MÔ TẢ (Condition Check)
      - So sánh tình trạng thực tế trong 'ẢNH CẦN CHECK' với 'MÔ TẢ CỦA NGƯỜI BÁN'.
      - Ví dụ: Người bán bảo "Mới tinh" nhưng ảnh thấy xước/rách -> Phải báo cáo là "Không đúng mô tả".
      - Ví dụ: Người bán bảo "Mất khóa" và ảnh đúng là không có khóa -> "Đúng mô tả".

      TRẢ VỀ ĐỊNH DẠNG JSON DUY NHẤT (Tiếng Việt tự nhiên, dành cho khách hàng đọc):
      {
        "result": "AUTHENTIC" | "FAKE" | "UNCERTAIN",
        "confidence": (số nguyên 0-100),
        "reason": "Viết một đoạn nhận xét ngắn (dưới 50 từ) như một chuyên gia nói với khách hàng. Ví dụ: 'Sản phẩm chuẩn Authentic. Các chi tiết logo và đường may khớp hoàn toàn với mẫu chính hãng. Tình trạng sản phẩm đúng như mô tả của người bán.' hoặc 'Cảnh báo: Form túi không chuẩn so với mẫu hãng, có dấu hiệu hàng giả.'"
      }
    TEXT

    messages_content << { type: "text", text: prompt_text }

    # Gửi ảnh mẫu
    messages_content << { type: "text", text: "--- ĐÂY LÀ ẢNH MẪU CHUẨN (REFERENCE) ---" }
    ref_urls.each { |url| messages_content << { type: "image_url", image_url: { url: url, detail: "low" } } }

    # Gửi ảnh User
    messages_content << { type: "text", text: "--- ĐÂY LÀ ẢNH SẢN PHẨM CẦN CHECK (USER UPLOAD) ---" }
    user_urls.each { |url| messages_content << { type: "image_url", image_url: { url: url, detail: "low" } } }

    # 5. GỬI REQUEST
    uri = URI("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{api_key}"

    request.body = {
      model: "gpt-4o", # Model tốt nhất cho việc nhìn ảnh và suy luận
      messages: [{ role: "user", content: messages_content }],
      max_tokens: 500,
      temperature: 0.2, # Giữ mức sáng tạo thấp để nhận xét nghiêm túc
      response_format: { type: "json_object" }
    }.to_json

    begin
      response = http.request(request)
      if response.code == "200"
        body = JSON.parse(response.body)
        parsed = JSON.parse(body.dig("choices", 0, "message", "content"))
        
        # Mapping trạng thái cho hệ thống
        new_status = case parsed["result"]
                     when "AUTHENTIC" 
                       # Nếu AI chắc chắn trên 80% thì mới cho Verify
                       parsed["confidence"].to_i >= 80 ? :verified : :manual_review
                     when "FAKE" then :rejected
                     else :manual_review
                     end
        
        # Lưu lời nhận xét vào Database để hiển thị cho khách
        final_note = "Độ tin cậy: #{parsed['confidence']}%. #{parsed['reason']}"
        listing.update!(status: new_status, ai_note: final_note)
      else
        error_msg = JSON.parse(response.body).dig("error", "message") rescue response.body
        listing.update!(status: :manual_review, ai_note: "Lỗi kết nối AI: #{error_msg}")
      end
    rescue => e
      listing.update!(status: :manual_review, ai_note: "Lỗi xử lý hệ thống: #{e.message}")
    end
  end
end