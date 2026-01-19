class Admin::DashboardController < Admin::BaseController
  def index
    @users_count    = User.count
    @listings_count = Listing.count
    @orders_pending = Order.where(status: :pending).count
  end
end
