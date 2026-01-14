class Order < ApplicationRecord
  belongs_to :listing
  belongs_to :buyer, class_name: "User"

  enum :status, {
    pending: 0,
    paid: 1,
    cancelled: 2
  }

  enum :kind, {
    auction_win: 0,
    buy_now: 1
  }

  validates :price, numericality: { greater_than: 0 }
  validates :listing_id, uniqueness: true

  after_create_commit :broadcast_sold

  def total_price
    (total.presence || price || 0).to_d
  end

  private

  def broadcast_sold
    ListingsChannel.broadcast_to(
      listing,
      {
        type: "sold",
        current_price: listing.current_price,
        order: {
          id: id,
          buyer_name: buyer.name,
          total: total_price
        }
      }
    )
  end
end
