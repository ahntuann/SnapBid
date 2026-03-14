class Admin::UsersController < Admin::BaseController
  def index
    @q = params[:q].to_s.strip
    scope = User.order(created_at: :desc)
    if @q.present?
      scope = scope.where("email ILIKE ? OR name ILIKE ?", "%#{@q}%", "%#{@q}%")
    end
    @users = scope.page(params[:page]).per(10)
  end

  def show
    @user = User.find(params[:id])
    @recent_listings = Listing.where(user_id: @user.id).order(created_at: :desc).limit(10)
    @recent_orders = Order.where(buyer_id: @user.id).order(created_at: :desc).limit(10)
    @recent_coin_transactions = @user.coin_transactions.order(created_at: :desc).limit(10)

    @listing_count = @user.listings.count
    @order_count = @user.orders.count
    @bid_count = @user.bids.count
    @watchlist_count = @user.watchlists.count

    @coins_in_total = @user.coin_transactions.where("amount > 0").sum(:amount)
    @coins_out_total = @user.coin_transactions.where("amount < 0").sum(:amount).abs
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "Đã cập nhật user."
    else
      flash.now[:alert] = "Cập nhật thất bại."
      render :edit, status: :unprocessable_entity
    end
  end

  def adjust_coins
    @user = User.find(params[:id])
    amount = params[:coin_adjustment_amount].to_i
    reason = params[:coin_adjustment_reason].to_s.strip

    if amount == 0
      redirect_to admin_user_path(@user), alert: "Số coin điều chỉnh phải khác 0."
      return
    end

    if reason.blank?
      redirect_to admin_user_path(@user), alert: "Vui lòng nhập lý do điều chỉnh coin."
      return
    end

    transaction_type = amount.positive? ? :deposit : :withdrawal
    description = "Admin ##{current_user.id} điều chỉnh coin: #{reason}"

    @user.process_coin_transaction!(
      amount: amount,
      transaction_type: transaction_type,
      description: description
    )

    redirect_to admin_user_path(@user), notice: "Đã điều chỉnh #{amount.positive? ? '+' : ''}#{amount} coin cho user."
  rescue StandardError => e
    redirect_to admin_user_path(@user), alert: "Điều chỉnh coin thất bại: #{e.message}"
  end

  def lock_account
    @user = User.find(params[:id])
    reason = params[:lock_reason].to_s.strip

    if @user.lock_account!
      redirect_to admin_user_path(@user), notice: "Đã khóa tài khoản user. Lý do: #{reason.presence || '(không có)'}"
    else
      redirect_to admin_user_path(@user), alert: "Khóa tài khoản thất bại."
    end
  rescue StandardError => e
    redirect_to admin_user_path(@user), alert: "Lỗi: #{e.message}"
  end

  def unlock_account
    @user = User.find(params[:id])

    if @user.unlock_account!
      redirect_to admin_user_path(@user), notice: "Đã mở khóa tài khoản user."
    else
      redirect_to admin_user_path(@user), alert: "Mở khóa tài khoản thất bại."
    end
  rescue StandardError => e
    redirect_to admin_user_path(@user), alert: "Lỗi: #{e.message}"
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end
end
