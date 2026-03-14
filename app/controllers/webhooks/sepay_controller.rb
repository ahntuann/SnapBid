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
        Rails.logger.info("[SePay Webhook] Not an inbound transfer, ignoring")
        return render json: { success: false, message: "Not an inbound transfer" }, status: :ok
      end

      transaction_id  = payload["id"].to_s
      content         = payload["content"].to_s.upcase
      amount_vnd      = payload["transferAmount"].to_i

      Rails.logger.info("[SePay Webhook] Processing: TxID=#{transaction_id}, Amount=#{amount_vnd} VND, Content=#{content}")

      # Tránh xử lý trùng
      if CoinDeposit.exists?(sepay_transaction_id: transaction_id)
        Rails.logger.info("[SePay Webhook] Transaction #{transaction_id} already processed, skipping")
        return render json: { success: true, message: "Already processed" }, status: :ok
      end

      # Tìm user theo deposit_ref SBC{id} trong nội dung CK
      match = content.match(/SBC(\d+)/)
      unless match
        Rails.logger.warn("[SePay Webhook] No SBC deposit ref found in content: #{content}")
        return render json: { success: false, message: "No deposit ref found" }, status: :ok
      end

      user_id = match[1].to_i
      user = User.find_by(id: user_id)
      unless user
        Rails.logger.warn("[SePay Webhook] User ##{user_id} not found")
        return render json: { success: false, message: "User not found" }, status: :ok
      end

      Rails.logger.info("[SePay Webhook] Found user ##{user.id} (#{user.email}), Amount: #{amount_vnd} VND")

      if amount_vnd < User::COIN_EXCHANGE_RATE
        Rails.logger.warn("[SePay Webhook] Amount #{amount_vnd} too small to credit any coins (threshold: #{User::COIN_EXCHANGE_RATE})")
        return render json: { success: false, message: "Amount too small" }, status: :ok
      end

      coins = user.credit_coins!(amount_vnd: amount_vnd, transaction_id: transaction_id)

      Rails.logger.info("[SePay Webhook] Successfully credited #{coins} coins to user ##{user.id}, new balance: #{user.reload.snapbid_coins}")

      NotificationService.notify!(
        recipient: user,
        actor: nil,
        action: :payment_confirmed,
        notifiable: nil,
        url: "/wallet",
        message: "Nạp thành công #{coins} SnapBid Coin (#{ActionController::Base.helpers.number_with_delimiter(amount_vnd)}₫). Số dư hiện tại: #{user.coin_balance} coin."
      )

      # Attempt auto-pay on any pending orders the user might have
      processed_orders = 0
      user.orders.pending.find_each do |order|
        if order.auto_pay_if_possible!
          processed_orders += 1
          Rails.logger.info("[SePay Webhook] Auto-paid Order ##{order.id} for user ##{user.id}")
        end
      end

      render json: { success: true, message: "Credited #{coins} coins to user ##{user.id}. Auto-paid #{processed_orders} orders.", coins: coins, balance: user.snapbid_coins }, status: :ok

    rescue => e
      Rails.logger.error("[SePay Webhook] Error: #{e.message}")
      Rails.logger.error("[SePay Webhook] Backtrace: #{e.backtrace[0..4].join("\n")}")
      render json: { success: false, message: "Internal error: #{e.message}" }, status: :ok
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
