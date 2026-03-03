class Admin::SettingsController < Admin::BaseController
  before_action :set_settings

  def show
    @admin_qr_payload = ENV["ADMIN_QR_PAYLOAD"]
  end

  def edit
  end

  def update
    if @settings.update(settings_params)
      redirect_to admin_settings_path, notice: "Updated settings"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_settings
    @settings = SystemSetting.first || SystemSetting.create(ai_threshold: 0.85, commission_percent: 5.0, min_bid_step: 10.0)
  end

  def settings_params
    params.require(:system_setting).permit(:ai_threshold, :commission_percent, :min_bid_step)
  end
end
