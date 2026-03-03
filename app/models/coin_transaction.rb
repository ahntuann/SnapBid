class CoinTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :subject, polymorphic: true, optional: true

  enum :transaction_type, {
    deposit: 0,
    withdrawal: 1,
    bid_fee: 2,
    refund: 3,
    payment: 4,
    welcome_bonus: 5
  }

  validates :amount, presence: true
  validates :balance_after, presence: true
  validates :transaction_type, presence: true
end
