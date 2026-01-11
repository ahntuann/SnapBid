class UserMailer < ApplicationMailer
  def otp_email(user, code)
    @user = user
    @code = code
    mail(to: user.email, subject: "SnapBid OTP Code")
  end
end
