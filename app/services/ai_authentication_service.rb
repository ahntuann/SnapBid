require "base64"
require "json"

class AiAuthenticationService
  def self.verify_listing!(listing)
    listing.update!(status: :submitted_for_ai)

    result = ENV["AI_MOCK"] == "true" ? mock_result : call_openai_vision!(listing)

    mapped_status = map_status(result[:status], result[:confidence])
    listing.update!(status: mapped_status, ai_note: result[:reason])

    listing.ai_verifications.create!(
      status: result[:status],
      confidence: result[:confidence],
      reason: result[:reason],
      raw_response: result[:raw]
    )
  rescue => e
    listing.update!(status: :manual_review, ai_note: "Lỗi khi gọi AI: #{e.message}")
    raise
  end

  def self.mock_result
    statuses = %w[verified rejected uncertain]
    status = statuses.sample
    confidence = rand(0.7..0.99).round(2)
    {
      status: status,
      confidence: confidence,
      reason: "Kết quả mô phỏng để demo. Trạng thái: #{status}, độ tin cậy: #{confidence}.",
      raw: { mock: true }
    }
  end

  def self.map_status(raw_status, confidence)
    threshold = 0.85
    case raw_status.to_s
    when "verified"
      confidence >= threshold ? :verified : :manual_review
    when "rejected"
      :rejected
    else
      :manual_review
    end
  end

  def self.call_openai_vision!(listing)
    binding.pry
    api_key = ENV.fetch("OPENAI_API_KEY")

    images = listing.images.first(4).map do |img|
      bytes = img.download
      b64 = Base64.strict_encode64(bytes)
      { type: "input_image", image_url: "data:image/jpeg;base64,#{b64}" }
    end

    prompt = <<~PROMPT
      Bạn là chuyên gia kiểm định hàng hoá.
      Hãy đánh giá tính xác thực sản phẩm dựa trên ẢNH và mô tả.

      Mô tả phân loại do người bán cung cấp:
      #{listing.seller_note}

      Trả về CHỈ JSON hợp lệ:
      {
        "status": "verified" | "rejected" | "uncertain",
        "confidence": 0.0..1.0,
        "reason": "Giải thích ngắn gọn bằng tiếng Việt"
      }
    PROMPT

    conn = Faraday.new(url: "https://api.openai.com") do |f|
      f.request :json
      f.response :json
      f.options.timeout = 60
    end

    resp = conn.post("/v1/chat/completions") do |req|
      req.headers["Authorization"] = "Bearer #{api_key}"
      req.headers["Content-Type"] = "application/json"
      req.body = {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "Chỉ trả về JSON hợp lệ. Không thêm chữ khác." },
          { role: "user", content: [{ type: "input_text", text: prompt }, *images] }
        ],
        temperature: 0.2
      }
    end

    content = resp.body.dig("choices", 0, "message", "content").to_s
    parsed = JSON.parse(content) rescue {}

    {
      status: (parsed["status"] || "uncertain"),
      confidence: (parsed["confidence"] || 0.0).to_f,
      reason: (parsed["reason"] || "Không có giải thích"),
      raw: resp.body
    }
  end
end
