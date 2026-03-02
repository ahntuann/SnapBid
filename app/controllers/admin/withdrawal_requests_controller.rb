class Admin::WithdrawalRequestsController < Admin::BaseController
  def index
    @withdrawal_requests = WithdrawalRequest.includes(:user).order(status: :asc, created_at: :desc)
    @withdrawal_requests = @withdrawal_requests.page(params[:page]).per(20) if defined?(Kaminari)
  end

  def show
    @withdrawal_request = WithdrawalRequest.find(params[:id])
  end

  def approve
    @withdrawal_request = WithdrawalRequest.find(params[:id])
    
    if params[:transfer_image].blank?
      redirect_to admin_withdrawal_request_path(@withdrawal_request), alert: "Vui lòng đính kèm ảnh bằng chứng chuyển khoản."
      return
    end
    
    if @withdrawal_request.pending?
      @withdrawal_request.transfer_image.attach(params[:transfer_image])
      @withdrawal_request.update!(status: :completed)
      
      Notification.create!(
        recipient: @withdrawal_request.user,
        action: 4, # system_notification
        message: "Yêu cầu rút #{ActionController::Base.helpers.number_with_delimiter(@withdrawal_request.amount)} Coin (##{@withdrawal_request.id}) đã được phê duyệt.",
        url: withdrawal_requests_path
      )
      
      redirect_to admin_withdrawal_request_path(@withdrawal_request), notice: "Đã duyệt yêu cầu rút tiền."
    else
      redirect_to admin_withdrawal_request_path(@withdrawal_request), alert: "Yêu cầu này không ở trạng thái chờ duyệt."
    end
  end

  def reject
    @withdrawal_request = WithdrawalRequest.find(params[:id])
    
    if @withdrawal_request.pending?
      ActiveRecord::Base.transaction do
        @withdrawal_request.update!(status: :rejected)
        # Refund coins
        @withdrawal_request.user.process_coin_transaction!(
          amount: @withdrawal_request.amount,
          transaction_type: :refund,
          description: "Hoàn tiền lệnh rút bị từ chối (##{@withdrawal_request.id})",
          subject: @withdrawal_request
        )
        
        Notification.create!(
          recipient: @withdrawal_request.user,
          action: 4, # system_notification
          message: "Yêu cầu rút #{ActionController::Base.helpers.number_with_delimiter(@withdrawal_request.amount)} Coin (##{@withdrawal_request.id}) đã bị từ chối và coin đã được hoàn lại.",
          url: withdrawal_requests_path
        )
      end
      
      redirect_to admin_withdrawal_request_path(@withdrawal_request), notice: "Đã từ chối yêu cầu và hoàn lại coin cho người dùng."
    else
      redirect_to admin_withdrawal_request_path(@withdrawal_request), alert: "Yêu cầu này không ở trạng thái chờ duyệt."
    end
  end

end
