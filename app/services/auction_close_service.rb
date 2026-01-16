class AuctionCloseService
  Result = Struct.new(:status, :order, :error, keyword_init: true)

  def self.call!(listing:)
    Rails.logger.info("[AuctionCloseService] listing=#{listing.id} ends_at=#{listing.auction_ends_at} now=#{Time.current} bids=#{listing.bids.count} order?=#{listing.order.present?}")
    ActiveRecord::Base.transaction do
      listing.lock!
      listing.reload

      return Result.new(status: :ignored) if listing.order.present?
      return Result.new(status: :ignored) if listing.auction_ends_at.blank?
      return Result.new(status: :ignored) if Time.current < listing.auction_ends_at

      winner_bid = listing.bids.order(amount: :desc, created_at: :asc).first

      if winner_bid.nil?
        # Không có bid => kết thúc không winner
        # listing.update!(auction_ended_at: Time.current) # đổi theo field bạn đang dùng
        ListingsChannel.broadcast_to(
          listing,
          { type: "ended", has_winner: false }
        )
        return Result.new(status: :ended_no_winner)
      end

      order = Order.create!(
        listing: listing,
        buyer: winner_bid.user,
        kind: :auction_win,
        status: :pending,
        price: winner_bid.amount
      )

    #   listing.update!(auction_ended_at: Time.current)
      ListingsChannel.broadcast_to(
          listing,
          { type: "ended", has_winner: true }
      )

      # tạo xong order => order.after_create_commit đã broadcast "sold"
      Result.new(status: :ended_with_winner, order: order)
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(status: :error, error: e.record.errors.full_messages.to_sentence)
  end
end
