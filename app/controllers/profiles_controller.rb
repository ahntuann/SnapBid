class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show; end
  def edit; end

  def update
    if current_user.update(profile_params)
      redirect_to profile_path, notice: "Cập nhật thông tin thành công."
    else
      flash.now[:alert] = "Cập nhật thất bại."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy_avatar
    current_user.avatar.purge_later if current_user.avatar.attached?
    redirect_to edit_profile_path, notice: "Đã xoá avatar."
  end

  private

  def profile_params
    params.require(:user).permit(:name, :avatar)
  end
end
