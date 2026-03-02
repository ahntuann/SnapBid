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
        
        # Hoàn tiền cho tất cả mọi người đã bid (nếu có, dù ở đây k có first bid nên sẽ ko có ai)
        RefundService.refund_losers!(listing: listing, winner: nil)
        
        return Result.new(status: :ended_no_winner)
      end

      # Discount amount dựa trên số coin đã tiêu
      coins_spent = winner_bid.user.coins_spent_on_listing(listing.id)
      discount_amount = coins_spent * 1000 # 1 coin = 1000d

      final_price = winner_bid.amount
      final_total = final_price - discount_amount
      final_total = 0 if final_total < 0 # Đảm bảo không âm

      order = Order.create!(
        listing: listing,
        buyer: winner_bid.user,
        kind: :auction_win,
        status: :pending,
        price: final_price,
        total: final_total
      )

      # Auto-pay or schedule expiration
      order.auto_pay_if_possible!
      if order.pending?
        ExpireUnpaidOrderJob.set(wait: 24.hours).perform_later(order.id)
      end

      # Hoàn tiền cho những người thua cuộc
      RefundService.refund_losers!(listing: listing, winner: winner_bid.user)

      NotificationService.notify!(
        recipient: winner_bid.user,
        actor: listing.user, # seller
        action: :auction_won,
        notifiable: listing,
        url: Rails.application.routes.url_helpers.order_path(order),
        message: "Bạn đã thắng đấu giá sản phẩm “#{listing.title}”. Vui lòng vào đơn hàng để thanh toán."
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
