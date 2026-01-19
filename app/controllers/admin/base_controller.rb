class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :require_admin!

  private

  def require_admin!
    return if current_user.respond_to?(:admin?) && current_user.admin?

    sign_out current_user
    redirect_to admin_login_path, alert: "Bạn không có quyền admin."
  end
end
