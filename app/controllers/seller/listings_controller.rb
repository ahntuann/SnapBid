class Seller::ListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: %i[show edit update submit_ai_verification]

  skip_before_action :verify_authenticity_token, only: [:update]

  def index
    tab = params[:tab].presence || "active" 
    base = current_user.listings.order(created_at: :desc)
    @tab = tab

    @listings =
      case tab
      when "sold"
        base.joins(:order).merge(Order.where.not(status: :cancelled))
      when "cancelled"
        base.joins(:order).merge(Order.where(status: :cancelled))
      else
        base.left_outer_joins(:order).where(orders: { id: nil })
      end

    @listings = @listings.page(params[:page]).per(4)
  end

  def show
  end

  def new
    @listing = current_user.listings.new
  end

  def create
    @listing = current_user.listings.new(listing_attribute_params)

    if @listing.save
      apply_cover_image_selection!(@listing, cover_image_index_param)
      current_user.promote_to_seller!
      redirect_to seller_listing_path(@listing), notice: "Đã tạo sản phẩm."
    else
      # flash.now[:alert] = @listing.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # 1. Kiểm tra xem người dùng có upload ảnh mới không
    # (Loại bỏ các giá trị rỗng nếu có)
    attrs = listing_attribute_params
    new_images = attrs[:images]&.reject(&:blank?)

    if new_images.present?
      # 2. Nếu có ảnh mới -> XÓA SẠCH ảnh cũ để đảm bảo chỉ còn đúng 8 ảnh mới
      @listing.images.purge 
    end

    if @listing.update(attrs)
      apply_cover_image_selection!(@listing, cover_image_index_param)
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
      :title, :category_id, :condition, :seller_note, :published_at,
      :start_price, :auction_ends_at, :bid_increment, :reserve_price, :buy_now_price,
      :cover_image_index,
      :reference_item_id,
      images: []
    )
  end

  def listing_attribute_params
    listing_params.except(:cover_image_index)
  end

  def cover_image_index_param
    raw = listing_params[:cover_image_index]
    return nil if raw.blank?

    raw.to_i
  end

  def apply_cover_image_selection!(listing, cover_index)
    return if cover_index.nil?

    attachments = listing.images.attachments.to_a
    return if attachments.empty?
    return if cover_index.negative? || cover_index >= attachments.length

    selected = attachments[cover_index]
    return if selected == attachments.first

    ordered_blobs = ([selected] + attachments.reject { |att| att.id == selected.id }).map(&:blob)

    # Detach để giữ blob hiện có, rồi gắn lại theo thứ tự mới.
    listing.images.detach
    ordered_blobs.each { |blob| listing.images.attach(blob) }
  end
end