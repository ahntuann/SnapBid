class ListingsController < ApplicationController
  skip_before_action :require_verified_email!, only: [:index, :show]
  before_action :set_listing, only: [:show, :buy_now]
  before_action :authenticate_user!, only: [:buy_now]

  def index
    @listings = Listing.published
  end

  def show
    @bid = Bid.new
  end

  def buy_now
    if @listing.user_id == current_user.id
      redirect_to listing_path(@listing), alert: t("errors.buy_now.cannot_buy_own")
      return
    end

    unless @listing.buy_now_available?
      redirect_to listing_path(@listing), alert: t("errors.buy_now.not_available")
      return
    end

    order = BuyNowService.call!(listing: @listing, user: current_user)
    redirect_to order_path(order), notice: t("notices.buy_now.success")
  rescue BuyNowService::NotAvailable
    redirect_to listing_path(@listing), alert: t("errors.buy_now.not_available")
  rescue ActiveRecord::RecordNotUnique
    redirect_to listing_path(@listing), alert: t("errors.listing.already_sold")
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end
end
