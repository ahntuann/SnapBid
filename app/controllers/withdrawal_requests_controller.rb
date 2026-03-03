class WithdrawalRequestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @withdrawal_requests = current_user.withdrawal_requests.order(created_at: :desc)
  end

  def new
    @withdrawal_request = current_user.withdrawal_requests.build
  end

  def create
    @withdrawal_request = current_user.withdrawal_requests.build(withdrawal_request_params)
    
    if @withdrawal_request.save
      redirect_to withdrawal_requests_path, notice: "Yêu cầu rút tiền đã được gửi và đang chờ xử lý."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def withdrawal_request_params
    params.require(:withdrawal_request).permit(:amount, :bank_name, :account_number, :account_name)
  end
end
