# app/channels/orders_channel.rb
class OrdersChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    stream_from "admin_orders" if current_user.admin?
  end
end
