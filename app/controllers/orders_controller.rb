class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :update, :mark_paid]

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
  end

  def update
    unless @order.pending?
      redirect_to @order, alert: "Đơn hàng không ở trạng thái pending."
      return
    end

    if @order.update(order_params)
      redirect_to @order, notice: "Đã lưu thông tin nhận hàng."
    else
      flash.now[:alert] = @order.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  def mark_paid
    unless @order.pending?
      redirect_to @order, alert: "Đơn hàng không ở trạng thái chờ thanh toán."
      return
    end

    unless @order.shipping_info_complete?
      redirect_to @order, alert: "Vui lòng nhập đầy đủ Tên / SĐT / Địa chỉ trước khi xác nhận đã chuyển tiền."
      return
    end

    @order.mark_paid_by_buyer!
    redirect_to @order, notice: "Đã ghi nhận bạn đã chuyển tiền. Vui lòng chờ admin xác nhận."
  end

  private

  def order_params
    params.require(:order).permit(:recipient_name, :recipient_phone, :shipping_address)
  end

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
