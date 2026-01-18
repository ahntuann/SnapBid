class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    NotificationsChannel.stream_for(current_user)
  end
end
