class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_verified_email!

  private

  def require_verified_email!
    return unless user_signed_in?
    return if current_user.email_verified?
    return if controller_name == "email_verifications"
    return if (controller_path.start_with?("devise/") || controller_path.start_with?("users/"))

    redirect_to new_email_verification_path, alert: "Please verify your email first"
  end

end
