class BidsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, except: [:mine]

  def create
    @listing = Listing.find(params[:listing_id])
    amount = params.dig(:bid, :amount).to_d

    # ✅ RULE MỚI: bid >= buy_now => bắt confirm, nếu không confirm thì không tạo bid
    if @listing.buy_now_enabled? && @listing.buy_now_price.present? && amount >= @listing.buy_now_price.to_d
        if params[:confirm_buy_now] == "1"
        order = BuyNowService.call!(listing: @listing, user: current_user)
        redirect_to order_path(order), notice: "Bạn đã mua ngay với giá #{@listing.buy_now_price}."
        else
        redirect_to listing_path(@listing), alert: "Giá bạn nhập ≥ giá mua ngay. Nếu muốn tiếp tục, hệ thống sẽ MUA NGAY với giá #{@listing.buy_now_price}."
        end
        return
    end

    # ✅ Bình thường: đặt bid
    result = BidService.place!(listing: @listing, user: current_user, amount: amount)

    if result.status == :bid_placed
        redirect_to listing_path(@listing), notice: "Đặt giá thành công."
    else
        redirect_to listing_path(@listing), alert: result.error
    end
  end

  def mine
    listing_ids = current_user.bids.select(:listing_id).distinct

    @listings = Listing
      .where(id: listing_ids)
      .includes(:category, :order, :bids, images_attachments: :blob)
      .order(Arel.sql("(
        SELECT MAX(bids.created_at)
        FROM bids
        WHERE bids.listing_id = listings.id
          AND bids.user_id = #{current_user.id}
      ) DESC"))
      .page(params[:page]).per(10)
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def bid_params
    params.require(:bid).permit(:amount)
  end
end
