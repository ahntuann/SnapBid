class Listing < ApplicationRecord
  belongs_to :user # seller

  has_many_attached :images

  has_many :bids, dependent: :destroy
  has_one :order, dependent: :nullify # when sold, create an order

  enum :status, {
    draft: 0,
    submitted_for_ai: 1,
    verified: 2,
    rejected: 3,
    manual_review: 4,
    published: 5
  }

  scope :published, -> { where.not(published_at: nil).order(published_at: :desc) }

  after_initialize do
    self.status ||= :draft if new_record?
  end

  validates :title, presence: true
  validates :seller_note, presence: true

  validates :start_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :reserve_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :bid_increment, numericality: { greater_than: 0 }, allow_nil: true
  validates :buy_now_price, numericality: { greater_than: 0 }, allow_nil: true

  validate :buy_now_must_be_greater_or_equal_to_start_price

  def status_text
    I18n.t("enums.listing.status.#{status}")
  end

  # --- Auction helpers ---

  def auction_configured?
    start_price.present? && bid_increment.present? && auction_ends_at.present?
  end

  def auction_ended?
    auction_ends_at.present? && Time.current >= auction_ends_at
  end

  def sold?
    order.present?
  end

  def buy_now_enabled?
    buy_now_price.present? && buy_now_price.to_d > 0
  end

  def current_price
    highest = bids.maximum(:amount)
    (highest || start_price || 0).to_d
  end

  def min_next_bid
    (current_price + (bid_increment || 1)).to_d
  end

  def highest_bid
    bids.order(amount: :desc, created_at: :asc).first
  end

  private

  def buy_now_must_be_greater_or_equal_to_start_price
    return if buy_now_price.blank? || start_price.blank?
    if buy_now_price.to_d < start_price.to_d
      errors.add(:buy_now_price, :greater_than_or_equal_to, count: start_price)
    end
  end
end
