class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :mark_paid]

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    # @order = Order.find(params[:id])

    # unless user_signed_in? && @order.buyer_id == current_user.id
    #   redirect_to root_path, alert: t("errors.order.forbidden")
    # end
  end

  def mark_paid
    if @order.pending?
      @order.mark_paid_by_buyer!
      redirect_to @order, notice: "Đã ghi nhận bạn đã chuyển tiền. Vui lòng chờ admin xác nhận."
    else
      redirect_to @order, alert: "Đơn hàng không ở trạng thái chờ thanh toán."
    end
  end

  private

  def set_order
    @order =
      if current_user&.admin?
        Order.find_by(id: params[:id])
      else
        current_user.orders.find_by(id: params[:id])
      end

    redirect_to root_path, alert: t("errors.order.forbidden") unless @order
  end
end
