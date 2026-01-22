class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc).limit(200)
  end

  def mark_read
    n = current_user.notifications.find(params[:id])
    n.mark_read!
    redirect_back fallback_location: notifications_path
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_back fallback_location: notifications_path
  end
end
