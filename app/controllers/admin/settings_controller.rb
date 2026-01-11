class Admin::SettingsController < Admin::BaseController
  def show
    @settings = SystemSetting.first
    @admin_qr_payload = ENV["ADMIN_QR_PAYLOAD"]
  end

  def edit
    @settings = SystemSetting.first
  end

  def update
    @settings = SystemSetting.first
    if @settings.update(settings_params)
      redirect_to admin_settings_path, notice: "Updated settings"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:system_setting).permit(:ai_threshold, :commission_percent, :min_bid_step)
  end
end
