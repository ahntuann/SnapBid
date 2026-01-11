class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      if user.persisted?
        otp, code = OtpService.generate!(user, purpose: "verify_email")
        UserMailer.otp_email(user, code).deliver_now
      end
    end
  end

  protected

  def after_sign_up_path_for(resource)
    new_email_verification_path
  end
end
