class Bid < ApplicationRecord
  belongs_to :listing
  belongs_to :user

  validates :amount, numericality: { greater_than: 0 }
  validate :listing_must_be_biddable
  validate :amount_must_be_high_enough
  validate :must_be_higher_than_minimum

  after_create_commit :broadcast_new_bid

  private

  # ===== Realtime =====
  def broadcast_new_bid
    ListingsChannel.broadcast_to(
      listing,
      {
        type: "new_bid",
        current_price: listing.current_price,
        bid: {
          user_name: user.name,
          amount: amount,
          created_at: I18n.l(created_at, format: :short)
        }
      }
    )
  end

  # ===== Validations =====
  def listing_must_be_biddable
    return if listing.present?

    errors.add(:listing, :blank)
    return
  end

  def amount_must_be_high_enough
    return if listing.blank? || amount.blank?

    if listing.sold?
      errors.add(:base, I18n.t("errors.bid.listing_sold"))
    elsif listing.auction_ended?
      errors.add(:base, I18n.t("errors.bid.auction_ended"))
    elsif listing.published_at.blank?
      errors.add(:base, I18n.t("errors.bid.not_published"))
    end
  end

  def must_be_higher_than_minimum
    return if listing.blank? || amount.blank?
    if amount.to_d < listing.min_next_bid
      errors.add(:amount, I18n.t("errors.bid.too_low", min: listing.min_next_bid))
    end
  end
end
