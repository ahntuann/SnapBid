class Seller::ListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: %i[show edit update submit_ai_verification]

  def index
    tab = params[:tab].presence || "active" 
    base = current_user.listings.order(created_at: :desc)
    @tab = tab

    @listings =
      if tab == "sold"
        base.joins(:order)
      else
        base.left_outer_joins(:order).where(orders: { id: nil })
      end
  end

  def show
  end

  def new
    @listing = current_user.listings.new
  end

  def create
    @listing = current_user.listings.new(listing_params)

    if @listing.save
      redirect_to seller_listing_path(@listing), notice: "Đã tạo sản phẩm."
    else
      flash.now[:alert] = @listing.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # 1. Kiểm tra xem người dùng có upload ảnh mới không
    # (Loại bỏ các giá trị rỗng nếu có)
    new_images = listing_params[:images]&.reject(&:blank?)

    if new_images.present?
      # 2. Nếu có ảnh mới -> XÓA SẠCH ảnh cũ để đảm bảo chỉ còn đúng 8 ảnh mới
      @listing.images.purge 
    end

    if @listing.update(listing_params)
      redirect_to seller_listing_path(@listing), notice: "Đã cập nhật sản phẩm."
    else
      flash.now[:alert] = @listing.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end
  # -----------------------------

  def submit_ai_verification
    AiAuthenticationService.verify_listing!(@listing)

    if @listing.verified?
      redirect_to edit_seller_listing_path(@listing), notice: "AI đã xác thực. Sản phẩm đã xuất hiện trên gian đấu giá."
    else
      redirect_to seller_listing_path(@listing), notice: "Đã gửi AI. Trạng thái: #{@listing.status_text}"
    end
  rescue => e
    redirect_to seller_listing_path(@listing), alert: "Lỗi AI: #{e.message}"
  end

  private

  def set_listing
    @listing = current_user.listings.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(
      :title, :category, :condition, :seller_note, :published_at,
      :start_price, :auction_ends_at, :bid_increment, :reserve_price, :buy_now_price,
      :reference_item_id,
      images: [] # Cho phép nhận mảng ảnh
    )
  end
end