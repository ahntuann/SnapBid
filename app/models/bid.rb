class Bid < ApplicationRecord
  belongs_to :listing
  belongs_to :user

  validates :amount, numericality: { greater_than: 0 }
  validate :listing_must_be_biddable
  validate :must_be_higher_than_minimum

  private

  def listing_must_be_biddable
    if listing.blank?
      errors.add(:listing, :blank)
      return
    end

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
