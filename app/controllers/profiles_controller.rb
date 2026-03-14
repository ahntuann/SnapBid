class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller!, only: %i[edit_shop update_shop]

  def show; end
  def edit; end

  def edit_shop; end

  def update
    if current_user.update(account_params)
      redirect_to profile_path, notice: "Cập nhật thông tin tài khoản thành công."
    else
      flash.now[:alert] = "Cập nhật thất bại."
      render :edit, status: :unprocessable_entity
    end
  end

  def update_shop
    if current_user.update(shop_params)
      redirect_to seller_path(current_user), notice: "Cập nhật thông tin gian hàng thành công."
    else
      flash.now[:alert] = "Cập nhật thất bại."
      render :edit_shop, status: :unprocessable_entity
    end
  end

  def destroy_avatar
    current_user.avatar.purge_later if current_user.avatar.attached?
    redirect_to edit_profile_path, notice: "Đã xoá avatar."
  end

  private

  def account_params
    params.require(:user).permit(:name, :avatar)
  end

  def shop_params
    params.require(:user).permit(:shop_name, :bio, :location)
  end

  def ensure_seller!
    redirect_to profile_path, alert: "Bạn chưa có gian hàng." unless current_user.seller?
  end
end
