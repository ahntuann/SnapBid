module Webhooks
  class SepayController < ActionController::Base
    # Bỏ CSRF - đây là endpoint nhận webhook từ bên ngoài
    skip_before_action :verify_authenticity_token

    before_action :verify_sepay_api_key

    # POST /webhooks/sepay
    # SePay gọi về mỗi khi có giao dịch chuyển khoản vào tài khoản.
    # Docs: https://docs.sepay.vn/webhook.html
    #
    # Payload mẫu:
    # {
    #   "id": 12345,
    #   "gateway": "MBBank",
    #   "transactionDate": "2024-01-01 12:00:00",
    #   "accountNumber": "0123456789",
    #   "content": "SNAPBID42 thanh toan",   ← chứa sepay_ref
    #   "transferType": "in",
    #   "transferAmount": 500000,
    #   "referenceCode": "FT24001ABCD",
    #   "description": "SNAPBID42"
    # }
    def create
      payload = JSON.parse(request.body.read) rescue {}

      Rails.logger.info("[SePay Webhook] Received: #{payload.inspect}")

      # Chỉ xử lý giao dịch NHẬN tiền
      unless payload["transferType"] == "in"
        return render json: { success: false, message: "Not an inbound transfer" }, status: :ok
      end

      content = payload["content"].to_s.upcase

      # Tìm đơn hàng theo sepay_ref trong nội dung CK
      order = Order.pending.find { |o| content.include?(o.sepay_ref.to_s.upcase) }

      unless order
        Rails.logger.warn("[SePay Webhook] No pending order matched content: #{content}")
        return render json: { success: false, message: "No matching order" }, status: :ok
      end

      # Kiểm tra số tiền khớp (cho phép sai lệch 1000đ)
      expected = order.total_price.to_i
      received = payload["transferAmount"].to_i

      if received < expected - 1000
        Rails.logger.warn("[SePay Webhook] Amount mismatch for order ##{order.id}: expected #{expected}, got #{received}")
        return render json: { success: false, message: "Amount mismatch" }, status: :ok
      end

      transaction_at = begin
        Time.zone.parse(payload["transactionDate"])
      rescue
        Time.current
      end

      order.auto_confirm_by_sepay!(transaction_at: transaction_at)

      Rails.logger.info("[SePay Webhook] Order ##{order.id} confirmed via SePay")

      render json: { success: true, message: "Order ##{order.id} confirmed" }, status: :ok

    rescue => e
      Rails.logger.error("[SePay Webhook] Error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
      render json: { success: false, message: "Internal error" }, status: :ok
    end

    private

    # SePay gửi header: Authorization: Apikey <your_api_key>
    def verify_sepay_api_key
      expected_key = Rails.application.credentials.dig(:sepay, :api_key) ||
                     ENV["SEPAY_API_KEY"]

      if expected_key.blank?
        Rails.logger.error("[SePay Webhook] SEPAY_API_KEY not configured!")
        render json: { success: false, message: "Server misconfiguration" }, status: :ok
        return
      end

      auth_header = request.headers["Authorization"].to_s
      provided_key = auth_header.sub(/\AApikey\s+/i, "").strip

      unless ActiveSupport::SecurityUtils.secure_compare(provided_key, expected_key)
        Rails.logger.warn("[SePay Webhook] Invalid API key received")
        render json: { success: false, message: "Unauthorized" }, status: :unauthorized
      end
    end
  end
end
