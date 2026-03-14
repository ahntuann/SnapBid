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

  def test_webhook
    @sepay_api_key = Rails.application.credentials.dig(:sepay, :api_key) || ENV["SEPAY_API_KEY"]
    @webhook_configured = @sepay_api_key.present?
    @test_users = User.where.not(id: 1..0).order(id: :desc).limit(20)
    @recent_deposits = CoinDeposit.order(created_at: :desc).limit(10)
  end

  def send_test_webhook
    user_id = params[:test_user_id].to_i
    amount_vnd = params[:test_amount].to_i

    if user_id <= 0 || amount_vnd <= 0
      render json: { success: false, error: "Invalid user ID or amount" }, status: :bad_request
      return
    end

    user = User.find_by(id: user_id)
    if !user
      render json: { success: false, error: "User not found" }, status: :not_found
      return
    end

    # Simulate SePay webhook call
    payload = {
      id: SecureRandom.random_number(999999),
      gateway: "AdminTest",
      transactionDate: Time.current.strftime("%Y-%m-%d %H:%M:%S"),
      accountNumber: "TestAccount",
      content: "#{user.deposit_ref} test deposit",
      transferType: "in",
      transferAmount: amount_vnd,
      referenceCode: "ADMIN-TEST-#{Time.current.to_i}"
    }

    begin
      coins = user.credit_coins!(amount_vnd: amount_vnd, transaction_id: payload[:id])
      
      render json: {
        success: true,
        message: "Test webhook executed successfully",
        user: { id: user.id, email: user.email, name: user.name },
        amount: amount_vnd,
        coins_credited: coins,
        new_balance: user.reload.snapbid_coins
      }, status: :ok
    rescue => e
      render json: {
        success: false,
        error: e.message
      }, status: :unprocessable_entity
    end
  end
end
