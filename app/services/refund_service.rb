class RefundService
  def self.refund_losers!(listing:, winner:)
    losing_users = User.joins(:bids).where(bids: { listing_id: listing.id })
    losing_users = losing_users.where.not(id: winner&.id) if winner.present?
    
    losing_users.distinct.each do |user|
      coins_spent = user.coins_spent_on_listing(listing.id)
      if coins_spent > 0
        user.process_coin_transaction!(
          amount: coins_spent,
          transaction_type: :refund,
          description: "Hoàn phí tham gia đấu giá cho sản phẩm ##{listing.id}",
          subject: listing
        )
      end
    end
  end
end
