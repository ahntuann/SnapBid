class BuyNowService
  class Error < StandardError; end
  class NotAvailable < Error; end

  def self.call!(listing:, user:)
    ActiveRecord::Base.transaction do
      listing.lock!
      listing.reload

      raise NotAvailable unless listing.buy_now_available?
      raise NotAvailable if listing.user_id == user.id # seller can't buy own item

      # Trừ phí "đặt giá" cho Mua Ngay như một lần đặt giá (nếu lần đầu tốn 5, lần sau tốn 1, tính giống bid thông thường)
      coins_needed = user.coins_needed_for_next_bid(listing.id)
      if user.snapbid_coins < coins_needed
        raise NotAvailable, "Không đủ SnapBid Coin để tham gia Mua Ngay (Cần #{coins_needed} coin). Vui lòng nạp thêm."
      end
      user.process_coin_transaction!(
        amount: -coins_needed,
        transaction_type: :bid_fee,
        description: "Phí tham gia mua ngay cho sản phẩm ##{listing.id}",
        subject: listing
      )
      
      # Tạo một record bid ảo hoặc đếm trực tiếp từ helper đã cộng
      # Tổng số coin chia cho listing = trước đó + lần này
      coins_spent = user.coins_spent_on_listing(listing.id) + coins_needed
      discount_amount = coins_spent * 1000 # 1 coin = 1000d
      
      final_price = listing.buy_now_price
      final_total = final_price - discount_amount
      final_total = 0 if final_total < 0 # Đảm bảo không âm tiền

      # Unique index on orders.listing_id guarantees only one winner
      order = Order.create!(
        listing: listing,
        buyer: user,
        kind: :buy_now,
        status: :pending,
        price: final_price,
        total: final_total
      )

      # Hoàn tiền cho người thua (nếu có ai từng bid trước đó)
      RefundService.refund_losers!(listing: listing, winner: user)

      # Auto-pay or schedule expiration
      order.auto_pay_if_possible!
      if order.pending?
        ExpireUnpaidOrderJob.set(wait: 24.hours).perform_later(order.id)
      end

      NotificationService.notify!(
        recipient: user,
        actor: listing.user,
        action: :buy_now_success,
        notifiable: listing,
        url: Rails.application.routes.url_helpers.order_path(order),
        message: "Bạn đã mua ngay sản phẩm “#{listing.title}”. Vui lòng vào đơn hàng để thanh toán."
      )
      order
    end
  end
end
