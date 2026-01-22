class Bid < ApplicationRecord
  belongs_to :listing
  belongs_to :user

  validates :amount, numericality: { greater_than: 0 }
  validate :listing_must_be_biddable
  validate :amount_must_be_high_enough
  validate :must_be_higher_than_minimum

  after_create_commit :broadcast_new_bid
  after_create_commit :notify_outbid

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

  # ✅ Notify người vừa bị vượt giá (previous top bid)
  def notify_outbid
    # Bid cao nhất trước đó (loại trừ bid hiện tại)
    previous = listing.bids
                      .where.not(id: id)
                      .order(amount: :desc, created_at: :asc)
                      .first
    return if previous.nil?

    outbid_user = previous.user
    return if outbid_user.id == user_id      # đừng tự notify chính mình
    return if listing.user_id == outbid_user.id # nếu seller có bid (hiếm) thì bỏ

    NotificationService.notify!(
      recipient: outbid_user,
      actor: user,
      action: :outbid,
      notifiable: listing,
      url: Rails.application.routes.url_helpers.listing_path(listing),
      message: "Có người đã trả giá cao hơn bạn cho sản phẩm “#{listing.title}”."
    )
    Rails.logger.info("############################################################################################################################")
    Rails.logger.info("[notify_outbid] bid=#{id} actor=#{user_id} prev=#{previous&.id} recipient=#{previous&.user_id}")
    Rails.logger.info("############################################################################################################################")
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
