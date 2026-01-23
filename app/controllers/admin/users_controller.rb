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

  private

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end
end
