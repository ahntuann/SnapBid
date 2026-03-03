class WithdrawalRequest < ApplicationRecord
  belongs_to :user

  enum :status, { pending: 0, completed: 1, rejected: 2 }
  has_one_attached :transfer_image

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :bank_name, presence: true
  validates :account_number, presence: true
  validates :account_name, presence: true

  validate :user_has_enough_coins, on: :create

  after_create :deduct_coins_from_user

  private

  def user_has_enough_coins
    if user && amount.present? && user.snapbid_coins < amount
      errors.add(:amount, "vượt quá số SnapBid Coins hiện có")
    end
  end

  def deduct_coins_from_user
    user.process_coin_transaction!(
      amount: -amount,
      transaction_type: :withdrawal,
      description: "Tạo lệnh rút #{amount} coin",
      subject: self
    )
  end
end
