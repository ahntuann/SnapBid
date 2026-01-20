class Order < ApplicationRecord
  belongs_to :listing
  belongs_to :buyer, class_name: "User"

  enum :status, {
    pending: 0,
    paid: 1,
    cancelled: 2
  }

  enum :kind, {
    auction_win: 0,
    buy_now: 1
  }

  validates :price, numericality: { greater_than: 0 }
  validates :listing_id, uniqueness: true
  # validates :recipient_name, presence: true, if: :pending?
  # validates :recipient_phone, presence: true, if: :pending?
  # validates :shipping_address, presence: true, if: :pending?

  after_create_commit :broadcast_sold
  after_update_commit :broadcast_payment_updates

  def received?
    received_at.present?
  end

  def confirm_received!
    update!(received_at: Time.current)
  end

  def total_price
    (total.presence || price || 0).to_d
  end

  def buyer_marked_paid?
    buyer_marked_paid_at.present?
  end

  def admin_confirmed_paid?
    admin_confirmed_paid_at.present?
  end

  def mark_paid_by_buyer!
    return if buyer_marked_paid?
    update!(buyer_marked_paid_at: Time.current)
  end

  def confirm_paid_by_admin!
    return if paid?
    update!(admin_confirmed_paid_at: Time.current, status: :paid)

    NotificationService.notify!(
      recipient: buyer,
      actor: nil,
      action: :payment_confirmed,
      notifiable: self,
      url: Rails.application.routes.url_helpers.order_path(self),
      message: "Admin đã xác nhận thanh toán cho đơn ##{id}. Đơn hàng đã hoàn tất."
    )
  end

  def shipping_info_complete?
    recipient_name.present? && recipient_phone.present? && shipping_address.present?
  end

  private

  def broadcast_sold
    ListingsChannel.broadcast_to(
      listing,
      {
        type: "sold",
        current_price: listing.current_price,
        order: {
          id: id,
          buyer_name: buyer.name,
          total: total_price
        }
      }
    )
  end

  def broadcast_payment_updates
    changed_payment =
      saved_change_to_buyer_marked_paid_at? ||
      saved_change_to_admin_confirmed_paid_at? ||
      saved_change_to_status?

    return unless changed_payment

    payload = {
      type: "order_payment_updated",
      order: {
        id: id,
        status: status,
        kind: kind,
        buyer_marked_paid_at: buyer_marked_paid_at&.iso8601,
        admin_confirmed_paid_at: admin_confirmed_paid_at&.iso8601
      }
    }

    # Buyer nhận realtime (đang mở orders/:id)
    OrdersChannel.broadcast_to(buyer, payload)

    # Admin nhận realtime (đang mở admin/orders hoặc show)
    ActionCable.server.broadcast("admin_orders", payload)
  end
end
