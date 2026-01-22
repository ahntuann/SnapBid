class BidService
  Result = Struct.new(:status, :bid, :order, :error, keyword_init: true)

  def self.place!(listing:, user:, amount:)
    amount = amount.to_d

    ActiveRecord::Base.transaction do
      listing.lock!
      listing.reload

      return Result.new(status: :error, error: I18n.t("errors.bid.auction_ended")) if listing.auction_ended?
      return Result.new(status: :error, error: I18n.t("errors.bid.listing_sold")) if listing.sold?

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
