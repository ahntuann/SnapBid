class OtpSessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      _otp, code = OtpService.generate!(user, purpose: "login")
      UserMailer.otp_email(user, code).deliver_later
      session[:otp_user_id] = user.id
      redirect_to verify_otp_session_path
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def verify
    redirect_to new_otp_session_path unless session[:otp_user_id]
  end

  def confirm
    user = User.find_by(id: session[:otp_user_id])
    return redirect_to new_otp_session_path unless user

    if OtpService.verify!(user, purpose: "login", code: params[:code])
      session.delete(:otp_user_id)
      sign_in(user)
      redirect_to root_path, notice: "Signed in with OTP"
    else
      flash.now[:alert] = "Invalid/expired OTP"
      render :verify, status: :unprocessable_entity
    end
  end
end
