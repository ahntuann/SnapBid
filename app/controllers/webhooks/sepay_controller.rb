module Webhooks
  class SepayController < ActionController::Base
    # Bỏ CSRF - đây là endpoint nhận webhook từ bên ngoài
    skip_before_action :verify_authenticity_token

    before_action :verify_sepay_api_key

    # POST /webhooks/sepay
    # SePay gọi về mỗi khi có giao dịch chuyển khoản vào tài khoản.
    # Dùng để nạp SnapBid Coin cho người dùng.
    # Nội dung CK phải chứa deposit_ref của user (VD: SBC42).
    #
    # Payload mẫu:
    # {
    #   "id": 12345,
    #   "gateway": "MBBank",
    #   "transactionDate": "2024-01-01 12:00:00",
    #   "accountNumber": "0123456789",
    #   "content": "SBC42 nap coin",
    #   "transferType": "in",
    #   "transferAmount": 50000,
    #   "referenceCode": "FT24001ABCD"
    # }
    def create
      payload = JSON.parse(request.body.read) rescue {}

      Rails.logger.info("[SePay Webhook] Received: #{payload.inspect}")

      # Chỉ xử lý giao dịch NHẬN tiền
      unless payload["transferType"] == "in"
        return render json: { success: false, message: "Not an inbound transfer" }, status: :ok
      end

      transaction_id  = payload["id"].to_s
      content         = payload["content"].to_s.upcase
      amount_vnd      = payload["transferAmount"].to_i

      # Tránh xử lý trùng
      if CoinDeposit.exists?(sepay_transaction_id: transaction_id)
        Rails.logger.info("[SePay Webhook] Transaction #{transaction_id} already processed")
        return render json: { success: true, message: "Already processed" }, status: :ok
      end

      # Tìm user theo deposit_ref SBC{id} trong nội dung CK
      match = content.match(/SBC(\d+)/)
      unless match
        Rails.logger.warn("[SePay Webhook] No SBC deposit ref found in content: #{content}")
        return render json: { success: false, message: "No deposit ref found" }, status: :ok
      end

      user = User.find_by(id: match[1].to_i)
      unless user
        Rails.logger.warn("[SePay Webhook] User not found for ref #{match[0]}")
        return render json: { success: false, message: "User not found" }, status: :ok
      end

      if amount_vnd < User::COIN_EXCHANGE_RATE
        Rails.logger.warn("[SePay Webhook] Amount #{amount_vnd} too small to credit any coins")
        return render json: { success: false, message: "Amount too small" }, status: :ok
      end

      coins = user.credit_coins!(amount_vnd: amount_vnd, transaction_id: transaction_id)

      NotificationService.notify!(
        recipient: user,
        actor: nil,
        action: :payment_confirmed,
        notifiable: nil,
        url: "/wallet",
        message: "Nạp thành công #{coins} SnapBid Coin (#{ActiveSupport::NumberHelper.number_to_delimited(amount_vnd)}₫). Số dư hiện tại: #{user.reload.coin_balance} coin."
      )

      Rails.logger.info("[SePay Webhook] Credited #{coins} coins to user ##{user.id}")

      render json: { success: true, message: "Credited #{coins} coins to user ##{user.id}" }, status: :ok

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
