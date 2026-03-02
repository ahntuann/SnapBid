class ExpireUnpaidOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find_by(id: order_id)
    return unless order
    
    # Cancel order if it's still unpaid (pending)
    if order.pending?
      order.cancel_expired_24h!
    end
  end
end
