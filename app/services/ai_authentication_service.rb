require 'net/http'
require 'uri'
require 'json'

class AiAuthenticationService
  def self.verify_listing!(listing)
    # 1. Kiểm tra điều kiện đầu vào
    unless listing.images.attached?
      listing.update!(
        status: :rejected,
        ai_note: "AI Từ chối: Không tìm thấy ảnh sản phẩm để phân tích."
      )
      return
    end

    # 2. Cập nhật trạng thái "Đang xử lý"
    listing.update!(status: :submitted_for_ai)

    # 3. Lấy API Key
    api_key = ENV['OPENAI_API_KEY']
    if api_key.blank?
      Rails.logger.error "MISSING OPENAI_API_KEY"
      listing.update!(status: :manual_review, ai_note: "Lỗi hệ thống: Chưa cấu hình API Key.")
      return
    end

    # 4. Lấy URL ảnh (Lấy ảnh đầu tiên)
    # Vì dùng Cloudinary nên url sẽ là link public
    image_url = listing.images.first.url

    # 5. Chuẩn bị Prompt (Câu lệnh)
    prompt_text = "Bạn là chuyên gia thẩm định hàng hiệu (Authenticator). 
    Hãy phân tích hình ảnh sản phẩm này dựa trên tên sản phẩm: '#{listing.title}' và mô tả: '#{listing.seller_note}'.
    
    Hãy trả lời CHÍNH XÁC theo format JSON sau (không thêm text thừa):
    {
      \"result\": \"AUTHENTIC\" hoặc \"FAKE\" hoặc \"UNCERTAIN\",
      \"confidence\": số điểm từ 0-100,
      \"reason\": \"Giải thích ngắn gọn tiếng Việt tại sao (dưới 50 từ)\"
    }"

    # 6. Cấu hình Request gửi OpenAI (ĐÂY LÀ ĐOẠN QUAN TRỌNG ĐỂ KHÔNG BỊ LỖI 400)
    uri = URI("https://api.openai.com/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 60 # Tăng thời gian chờ lên 60s

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{api_key}"

    request.body = {
      model: "gpt-4o", # Model xịn nhất, rẻ và nhanh
      messages: [
        {
          role: "user",
          content: [
            { 
              type: "text", 
              text: prompt_text 
            },
            { 
              type: "image_url", 
              image_url: {
                url: image_url,
                detail: "low" # Chọn low cho nhanh và tiết kiệm tiền
              }
            }
          ]
        }
      ],
      max_tokens: 300,
      temperature: 0.2, # Giảm sáng tạo để tăng độ chính xác
      response_format: { type: "json_object" } # Bắt buộc trả về JSON chuẩn
    }.to_json

    # 7. Gửi và Xử lý kết quả
    begin
      response = http.request(request)
      
      if response.code == "200"
        body = JSON.parse(response.body)
        content = body.dig("choices", 0, "message", "content")
        parsed_result = JSON.parse(content) # Parse JSON từ câu trả lời của AI

        # Mapping kết quả từ AI sang Status của Web
        new_status = case parsed_result["result"]
                     when "AUTHENTIC" then :verified
                     when "FAKE" then :rejected
                     else :manual_review
                     end
        
        # Lưu vào Database
        listing.update!(
          status: new_status,
          ai_note: "Độ tin cậy: #{parsed_result['confidence']}%. #{parsed_result['reason']}"
        )
      else
        # Xử lý khi API báo lỗi (400, 401, 429...)
        error_message = JSON.parse(response.body).dig("error", "message") rescue response.body
        Rails.logger.error "OpenAI Error: #{error_message}"
        listing.update!(
          status: :manual_review, 
          ai_note: "Lỗi kết nối AI: #{error_message}. Cần người duyệt."
        )
      end

    rescue => e
      Rails.logger.error "AI Service Exception: #{e.message}"
      listing.update!(status: :manual_review, ai_note: "Lỗi xử lý: #{e.message}")
    end
  end
end