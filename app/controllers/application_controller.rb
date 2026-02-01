class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_verified_email!, if: :user_signed_in?
  
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? } # Cho phép JSON API hoạt động mà không cần CSRF token

  def after_sign_in_path_for(resource)
    return new_email_verification_path if resource.is_a?(User) && !resource.email_verified?
    if resource.is_a?(User) && resource.admin?
      admin_root_path
    else
      root_path
    end
  end

  private

  def require_verified_email!
    return unless user_signed_in?
    return if current_user.email_verified?

    # Cho phép vào trang xác minh
    return if controller_name == "email_verifications"

    # Cho phép Devise và OAuth chạy bình thường
    return if devise_controller?
    return if controller_path == "users/omniauth_callbacks"
    return if controller_path == "users/registrations"

    redirect_to new_email_verification_path, alert: "Vui lòng xác minh email trước khi sử dụng hệ thống."
  end
  
  # Phương thức giúp phân biệt giữa yêu cầu từ trình duyệt và từ API
  # def json_request?
  #   request.format.json? || request.headers['Accept']&.include?('application/json')
  # end

end