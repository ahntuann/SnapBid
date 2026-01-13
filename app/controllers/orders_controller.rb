class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])

    unless user_signed_in? && @order.buyer_id == current_user.id
      redirect_to root_path, alert: t("errors.order.forbidden")
    end
  end
end
