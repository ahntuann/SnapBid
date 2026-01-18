class BuyNowService
  class Error < StandardError; end
  class NotAvailable < Error; end

  def self.call!(listing:, user:)
    ActiveRecord::Base.transaction do
      listing.lock!
      listing.reload

      raise NotAvailable unless listing.buy_now_available?
      raise NotAvailable if listing.user_id == user.id # seller can't buy own item

      # Unique index on orders.listing_id guarantees only one winner
      order = Order.create!(
        listing: listing,
        buyer: user,
        kind: :buy_now,
        status: :pending,
        price: listing.buy_now_price,
      )

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
