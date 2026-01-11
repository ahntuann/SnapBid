class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect user, event: :authentication
  rescue => e
    Rails.logger.error("Google OAuth error: #{e.message}")
    redirect_to new_user_session_path, alert: "Google login failed"
  end
end
