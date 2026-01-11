class EmailVerificationsController < ApplicationController
  before_action :authenticate_user!

  def new
    redirect_to root_path, notice: "Email already verified" if current_user.email_verified?
  end

  def create
    if OtpService.verify!(current_user, purpose: "verify_email", code: params[:code])
      current_user.update!(email_verified_at: Time.current)
      redirect_to root_path, notice: "Email verified successfully"
    else
      flash.now[:alert] = "Invalid/expired OTP"
      render :new, status: :unprocessable_entity
    end
  end

  def resend
    otp, code = OtpService.generate!(current_user, purpose: "verify_email")
    UserMailer.otp_email(current_user, code).deliver_now
    redirect_to new_email_verification_path, notice: "OTP resent"
  end
end
