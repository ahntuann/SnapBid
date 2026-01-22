class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    # SỬA LẠI DÒNG NÀY:
    stream_for current_user
  end
end