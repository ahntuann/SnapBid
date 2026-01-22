class Listing < ApplicationRecord
  belongs_to :user # seller
  belongs_to :reference_item, optional: true
  belongs_to :category, optional: true

  has_many_attached :images

  has_many :bids, dependent: :destroy
  has_one :order, dependent: :restrict_with_exception

  enum :status, {
    draft: 0,
    submitted_for_ai: 1,
    verified: 2,
    rejected: 3,
    manual_review: 4,
    published: 5
  }

  scope :published, -> {
    where.not(published_at: nil).order(published_at: :desc)
  }

  after_initialize do
    self.status ||= :draft if new_record?
  end

  after_commit :schedule_close_auction, on: [:create, :update]

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

  def ai_verified?
    verified?
  end

  def published?
    published_at.present?
  end

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

  def buy_now_available?
    buy_now_enabled? &&
      published_at.present? &&
      order.nil? &&
      !auction_ended?
  end

  def current_price
    return order.price.to_d if order.present?

    highest = bids.maximum(:amount)
    if highest.present?
      highest.to_d
    else
      (start_price || 0).to_d
    end
  end

  def min_next_bid
    base = current_price
    inc  = (bid_increment || 0).to_d
    base + inc
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

  def schedule_close_auction
    return if auction_ends_at.blank?

    # Job tự check thời gian + trạng thái nên gọi nhiều lần vẫn an toàn
    CloseAuctionJob
      .set(wait_until: auction_ends_at)
      .perform_later(id)
  end
end
