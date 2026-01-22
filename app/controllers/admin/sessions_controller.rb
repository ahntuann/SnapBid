class Admin::SessionsController < ApplicationController
  layout "admin_auth"

  def new; end

  def create
    email = params[:email].to_s.strip.downcase
    password = params[:password].to_s

    user = User.find_for_database_authentication(email: email)

    unless user&.valid_password?(password)
      flash.now[:alert] = "Email hoặc mật khẩu không đúng."
      return render :new, status: :unprocessable_entity
    end

    unless user.admin?
      flash.now[:alert] = "Tài khoản này không có quyền admin."
      return render :new, status: :unprocessable_entity
    end

    sign_in(user)
    redirect_to admin_root_path, notice: "Đăng nhập admin thành công."
  end

  def destroy
    sign_out(current_user) if user_signed_in?
    redirect_to root_path, notice: "Đã đăng xuất."
  end
end
