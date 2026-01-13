class BidsController < ApplicationController
  def create
    @listing = Listing.find(params[:listing_id])
    authenticate_user!

    if @listing.user_id == current_user.id
      redirect_to listing_path(@listing), alert: t("errors.bid.own_listing")
      return
    end

    @bid = @listing.bids.new(bid_params.merge(user: current_user))

    if @bid.save
      redirect_to listing_path(@listing), notice: t("flash.bid.placed")
    else
      redirect_to listing_path(@listing), alert: @bid.errors.full_messages.first
    end
  end

  private

  def bid_params
    params.require(:bid).permit(:amount)
  end
end
