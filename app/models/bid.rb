class Bid < ApplicationRecord
  belongs_to :listing
  belongs_to :user

  validates :amount, numericality: { greater_than: 0 }
  validate :listing_must_be_biddable
  validate :amount_must_be_high_enough
  validate :must_be_higher_than_minimum

  after_create_commit :broadcast_new_bid
  after_create_commit :notify_interested_users

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

  # ✅ Notify những người quan tâm (previous bidders + watchers)
  def notify_interested_users
    # 1. Lấy danh sách những người đã từng bid (loại trừ người vừa bid)
    bids_user_ids = listing.bids.where.not(user_id: user_id).pluck(:user_id).uniq
    
    # 2. Lấy danh sách những người đang theo dõi (loại trừ người vừa bid)
    watchers_user_ids = listing.watchlists.where.not(user_id: user_id).pluck(:user_id).uniq

    # 3. Hợp nhất danh sách
    recipient_ids = (bids_user_ids + watchers_user_ids).uniq
    
    # 4. Xác định người đang giữ giá cao nhất trước đó để gửi tin nhắn "bị vượt giá"
    previous_highest_bid = listing.bids
                                  .where.not(id: id)
                                  .order(amount: :desc, created_at: :asc)
                                  .first
    previous_highest_bidder_id = previous_highest_bid&.user_id

    recipient_ids.each do |recipient_id|
      recipient = User.find(recipient_id)
      
      # Không gửi cho seller (họ có notification riêng nếu cần, thường seller không bid)
      next if recipient.id == listing.user_id

      is_outbid = (recipient.id == previous_highest_bidder_id)
      
      action = is_outbid ? :outbid : :new_bid_on_watched_item
      message = if is_outbid
                  "Bạn đã bị vượt giá cho sản phẩm “#{listing.title}”. Giá mới là #{amount} ₫."
                else
                  "Sản phẩm “#{listing.title}” bạn quan tâm vừa có lượt đặt giá mới: #{amount} ₫."
                end

      NotificationService.notify!(
        recipient: recipient,
        actor: user,
        action: action,
        notifiable: listing,
        url: Rails.application.routes.url_helpers.listing_path(listing),
        message: message
      )
    end
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
