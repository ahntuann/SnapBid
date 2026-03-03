class CoinDeposit < ApplicationRecord
  belongs_to :user

  validates :amount_vnd,     presence: true, numericality: { greater_than: 0 }
  validates :coins_credited, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :deposit_ref,    presence: true
end
