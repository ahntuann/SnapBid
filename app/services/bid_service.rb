class BidService
  Result = Struct.new(:status, :bid, :order, :error, keyword_init: true)

  def self.place!(listing:, user:, amount:)
    amount = amount.to_d

    ActiveRecord::Base.transaction do
      listing.lock!
      listing.reload

      return Result.new(status: :error, error: I18n.t("errors.bid.auction_ended")) if listing.auction_ended?
      return Result.new(status: :error, error: I18n.t("errors.bid.listing_sold")) if listing.sold?

      coins_needed = user.coins_needed_for_next_bid(listing)
      if user.snapbid_coins < coins_needed
        return Result.new(status: :error, error: "Không đủ SnapBid Coin để tham gia trả giá (Cần #{coins_needed} coin). Vui lòng nạp thêm.")
      end

      # Chỉ trừ phí ở lần bid đầu tiên của user trên listing này.
      if coins_needed.positive?
        user.process_coin_transaction!(
          amount: -coins_needed,
          transaction_type: :bid_fee,
          description: "Phí đặt giá lần đầu (10% giá mua ngay) cho sản phẩm ##{listing.id}",
          subject: listing
        )
      end

      bid = listing.bids.create!(user: user, amount: amount)
      Result.new(status: :bid_placed, bid: bid)
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(status: :error, error: e.record.errors.full_messages.to_sentence)
  rescue BuyNowService::NotAvailable
    Result.new(status: :error, error: I18n.t("errors.buy_now.not_available"))
  rescue ActiveRecord::RecordNotUnique
    Result.new(status: :error, error: I18n.t("errors.listing.already_sold"))
  end
end
