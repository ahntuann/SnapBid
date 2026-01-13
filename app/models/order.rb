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
end
