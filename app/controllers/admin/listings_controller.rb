class Admin::ListingsController < Admin::BaseController
  def index
    @q = params[:q].to_s.strip
    scope = Listing.includes(:user).order(created_at: :desc)
    scope = scope.where("title ILIKE ?", "%#{@q}%") if @q.present?
    @listings = scope.page(params[:page]).per(12)
  end

  def show
    @listing = Listing.includes(:user, :bids, images_attachments: :blob).find(params[:id])
  end

  def edit
    @listing = Listing.find(params[:id])
  end

  def update
    @listing = Listing.find(params[:id])
    if @listing.update(listing_params)
      redirect_to admin_listing_path(@listing), notice: "Đã cập nhật listing."
    else
      flash.now[:alert] = "Cập nhật thất bại."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def listing_params
    params.require(:listing).permit(
      :title, :category, :condition, :seller_note,
      :start_price, :buy_now_price,
      :auction_ends_at, :published_at,
      :ai_status # nếu bạn có field này
    )
  end
end
