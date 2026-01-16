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
      Order.create!(
        listing: listing,
        buyer: user,
        kind: :buy_now,
        status: :pending,
        price: listing.buy_now_price,
      )
    end
  end
end
