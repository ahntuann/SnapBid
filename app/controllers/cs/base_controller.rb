class Cs::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :require_cs_or_admin!

  private

  def require_cs_or_admin!
    ok = current_user&.admin? || current_user&.cs?
    redirect_to root_path, alert: "Not authorized" unless ok
  end
end
