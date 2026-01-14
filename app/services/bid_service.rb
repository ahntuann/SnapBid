class BidService
  Result = Struct.new(:status, :bid, :order, :error, keyword_init: true)

  def self.place!(listing:, user:, amount:)
    amount = amount.to_d

    ActiveRecord::Base.transaction do
      listing.lock!
      listing.reload

      # If bid reaches/exceeds buy-now => execute buy-now at buy-now price
    #   if listing.buy_now_available? && amount >= listing.buy_now_price.to_d
    #     order = BuyNowService.call!(listing: listing, user: user)
    #     return Result.new(status: :bought_now, order: order)
    #   end

      bid = listing.bids.create!(user: user, amount: amount)
      Result.new(status: :bid_placed, bid: bid)
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(status: :error, error: e.record.errors.full_messages.to_sentence)
  rescue BuyNowService::NotAvailable
    Result.new(status: :error, error: I18n.t("errors.buy_now.not_available"))
  rescue ActiveRecord::RecordNotUnique
    # someone else already bought in the same moment
    Result.new(status: :error, error: I18n.t("errors.listing.already_sold"))
  end
end
