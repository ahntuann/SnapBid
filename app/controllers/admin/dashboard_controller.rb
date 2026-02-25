class Admin::DashboardController < Admin::BaseController
  def index
    # ── Stat counts ───────────────────────────────────────
    @users_count        = User.count
    @listings_count     = Listing.count
    @orders_count       = Order.count
    @categories_count   = Category.count
    @orders_pending     = Order.where(status: :pending).count
    @orders_paid        = Order.where(status: :paid).count

    # ── Listings by status (for donut chart) ──────────────
    @listings_by_status = Listing.group(:status).count

    # ── New users last 7 days (for line chart) ─────────────
    @users_by_day = User
      .where(created_at: 7.days.ago.beginning_of_day..)
      .group("DATE(created_at)")
      .order("DATE(created_at)")
      .count

    # ── New listings last 7 days ───────────────────────────
    @listings_by_day = Listing
      .where(created_at: 7.days.ago.beginning_of_day..)
      .group("DATE(created_at)")
      .order("DATE(created_at)")
      .count

    # ── Recent activity ────────────────────────────────────
    @recent_listings = Listing.includes(:user, :category)
                              .order(created_at: :desc)
                              .limit(8)

    @recent_orders   = Order.includes(:listing, :buyer)
                            .order(created_at: :desc)
                            .limit(6)
  end
end
