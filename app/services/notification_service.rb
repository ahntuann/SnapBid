class NotificationService
  def self.notify!(recipient:, action:, message:, url: nil, actor: nil, notifiable: nil)
    notification = Notification.create!(
      recipient: recipient,
      actor: actor,
      action: action,
      message: message,
      url: url,
      notifiable: notifiable
    )

    NotificationsChannel.broadcast_to(
      recipient,
      {
        type: "notification",
        notification: {
          id: notification.id,
          action: notification.action,
          message: notification.message,
          url: notification.url,
          created_at: notification.created_at.iso8601,
          read_at: notification.read_at&.iso8601
        }
      }
    )

    notification
  end
end
