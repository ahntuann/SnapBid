class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :update, :mark_paid, :pay_with_coins, :status]

  def index
    @orders = current_user.orders.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @coins_needed = User.vnd_to_coins(@order.total_price)
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

  # GET /orders/:id/status  –  JSON polling fallback cho order_controller.js
  def status
    render json: {
      id:                     @order.id,
      status:                 @order.status,
      paid:                   @order.paid?,
      buyer_marked_paid_at:   @order.buyer_marked_paid_at&.iso8601,
      admin_confirmed_paid_at: @order.admin_confirmed_paid_at&.iso8601
    }
  end

  # POST /orders/:id/pay_with_coins  – thanh toán bằng SnapBid Coin
  def pay_with_coins
    unless @order.pending?
      redirect_to @order, alert: "Đơn hàng không ở trạng thái chờ thanh toán."
      return
    end

    unless @order.shipping_info_complete?
      redirect_to @order, alert: "Vui lòng nhập đầy đủ Tên / SĐT / Địa chỉ trước khi thanh toán."
      return
    end

    coins_needed = User.vnd_to_coins(@order.total_price)
    if current_user.coin_balance < coins_needed
      redirect_to wallet_path, alert: "Số dư SnapBid Coin không đủ. Cần #{coins_needed} coin, hiện có #{current_user.coin_balance} coin. Vui lòng nạp thêm."
      return
    end

    @order.pay_with_coins!
    redirect_to @order, notice: "Thanh toán thành công bằng SnapBid Coin!"
  rescue => e
    redirect_to @order, alert: "Thanh toán thất bại: #{e.message}"
  end

  # Giữ lại mark_paid để tránh lỗi routing cũ (không dùng nữa)
  def mark_paid
    redirect_to @order
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
