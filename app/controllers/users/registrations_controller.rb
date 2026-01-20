class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def create
    super do |user|
      if user.persisted?
        otp, code = OtpService.generate!(user, purpose: "verify_email")
        UserMailer.otp_email(user, code).deliver_later
      end
    end
  end

  protected

  def after_sign_up_path_for(resource)
    new_email_verification_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
