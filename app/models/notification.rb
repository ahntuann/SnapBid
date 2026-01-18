class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  enum :action, {
    outbid: 0,
    auction_won: 1,
    buy_now_success: 2,
    payment_confirmed: 3
  }

  scope :unread, -> { where(read_at: nil) }

  validates :action, presence: true
  validates :message, presence: true

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end
end
