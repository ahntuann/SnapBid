require 'net/http'
require 'uri'
require 'json'

class AiAuthenticationService
  def self.verify_listing!(listing)
    # 1. Kiểm tra ảnh người dùng
    unless listing.images.attached?
      listing.update!(status: :rejected, ai_note: "AI Từ chối: Không có ảnh sản phẩm.")
      return
    end

    # 2. Kiểm tra ảnh mẫu (Reference)
    reference = listing.reference_item
    unless reference && reference.images.attached?
      # Nếu không có mẫu, fallback về chế độ kiểm tra chung (chỉ nhìn ảnh user)
      listing.update!(status: :manual_review, ai_note: "Chưa có dữ liệu mẫu (Reference Images) để so sánh. Cần duyệt tay.")
      return
    end

    listing.update!(status: :submitted_for_ai)

    # 3. Chuẩn bị dữ liệu gửi AI
    api_key = ENV['OPENAI_API_KEY']
    return if api_key.blank?

    # Lấy URL ảnh từ Cloudinary (Chỉ lấy tối đa 5 ảnh mỗi loại để tiết kiệm tiền)
    ref_urls = reference.images.first(5).map(&:url)
    user_urls = listing.images.first(5).map(&:url)

    # 4. Xây dựng nội dung Message (Phần quan trọng nhất)
    messages_content = []

    # A. Prompt hướng dẫn
    messages_content << {
      type: "text",
      text: "Bạn là chuyên gia thẩm định (Authenticator). Hãy so sánh 2 nhóm ảnh dưới đây để xác thực hàng thật/giả.
      \n- NHÓM 1: Ảnh mẫu chuẩn Authentic (Reference).
      \n- NHÓM 2: Ảnh sản phẩm người dùng đăng bán (Cần kiểm tra).
      \n
      Thông tin sản phẩm: #{listing.title}.
      Mô tả người bán: #{listing.seller_note}.
      \n
      Yêu cầu:
      1. So sánh chi tiết (logo, đường may, font chữ, chất liệu) giữa Nhóm 1 và Nhóm 2.
      2. Nếu Nhóm 2 có sai khác đáng kể so với Nhóm 1 => FAKE.
      3. Nếu Nhóm 2 giống Nhóm 1 nhưng ảnh mờ/thiếu góc chụp => UNCERTAIN.
      4. Nếu Nhóm 2 khớp hoàn toàn => AUTHENTIC.
      \n
      Trả về JSON duy nhất:
      {
        \"result\": \"AUTHENTIC\" | \"FAKE\" | \"UNCERTAIN\",
        \"confidence\": (0-100),
        \"reason\": \"Giải thích ngắn gọn tiếng Việt (tại sao giống/khác mẫu?)\"
      }"
    }

    # B. Gửi ảnh mẫu (Reference) - Có chú thích
    messages_content << { type: "text", text: "--- NHÓM 1: ẢNH MẪU CHUẨN (REFERENCE) ---" }
    ref_urls.each do |url|
      messages_content << { type: "image_url", image_url: { url: url, detail: "low" } }
    end

    # C. Gửi ảnh người dùng (User) - Có chú thích
    messages_content << { type: "text", text: "--- NHÓM 2: ẢNH NGƯỜI DÙNG CẦN CHECK ---" }
    user_urls.each do |url|
      messages_content << { type: "image_url", image_url: { url: url, detail: "low" } }
    end

    # 5. Cấu hình Request
    uri = URI("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120 # Chờ lâu hơn chút vì gửi nhiều ảnh

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{api_key}"

    request.body = {
      model: "gpt-4o",
      messages: [
        {
          role: "user",
          content: messages_content
        }
      ],
      max_tokens: 500,
      temperature: 0.1,
      response_format: { type: "json_object" }
    }.to_json

    # 6. Gửi và Xử lý
    begin
      response = http.request(request)
      
      if response.code == "200"
        body = JSON.parse(response.body)
        content = body.dig("choices", 0, "message", "content")
        parsed = JSON.parse(content)

        # Mapping status
        new_status = case parsed["result"]
                     when "AUTHENTIC"
                       parsed["confidence"].to_i >= 80 ? :verified : :manual_review
                     when "FAKE" then :rejected
                     else :manual_review
                     end

        listing.update!(
          status: new_status,
          ai_note: "#{parsed['result']} (#{parsed['confidence']}%): #{parsed['reason']}"
        )
      else
        error_msg = JSON.parse(response.body).dig("error", "message") rescue response.body
        listing.update!(status: :manual_review, ai_note: "Lỗi API: #{error_msg}")
      end
    rescue => e
      listing.update!(status: :manual_review, ai_note: "Lỗi xử lý: #{e.message}")
    end
  end
end