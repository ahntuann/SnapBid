module Admin
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    before_action :set_order, only: [:show, :confirm_paid]

    def index
      @orders = Order.order(created_at: :desc)
    end

    def show
    end

    def confirm_paid
      unless @order.buyer_marked_paid?
        return redirect_to admin_order_path(@order), alert: "Buyer chưa bấm xác nhận đã chuyển tiền."
      end

      @order.confirm_paid_by_admin!
      redirect_to admin_order_path(@order), notice: "Đã xác nhận nhận tiền. Đơn hàng chuyển sang ĐÃ THANH TOÁN."
    end

    private

    def require_admin!
      redirect_to root_path, alert: "Không có quyền." unless current_user.admin?
    end

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
