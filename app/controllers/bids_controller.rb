class BidsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing

  def create
    result = BidService.place!(
      listing: @listing,
      user: current_user,
      amount: bid_params[:amount]
    )

    if result.status == :bid_placed
      redirect_to listing_path(@listing), notice: t("notices.bid.placed")
    elsif result.status == :bought_now
      redirect_to order_path(result.order), notice: t("notices.buy_now.success")
    else
      redirect_to listing_path(@listing), alert: result.error
    end
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def bid_params
    params.require(:bid).permit(:amount)
  end
end
