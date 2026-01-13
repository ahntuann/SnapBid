class ListingsController < ApplicationController
  skip_before_action :require_verified_email!, only: [:index, :show]

  def index
    @listings = Listing.published
  end

  def show
    @listing = Listing.find(params[:id])
    @bid = Bid.new
  end

  def buy_now
    @listing = Listing.find(params[:id])
    authenticate_user!

    if @listing.user_id == current_user.id
      redirect_to listing_path(@listing), alert: t("errors.buy_now.own_listing")
      return
    end

    if @listing.sold?
      redirect_to listing_path(@listing), alert: t("errors.buy_now.sold")
      return
    end

    unless @listing.buy_now_enabled?
      redirect_to listing_path(@listing), alert: t("errors.buy_now.not_enabled")
      return
    end

    Order.transaction do
      Order.create!(
        listing: @listing,
        buyer: current_user,
        kind: :buy_now,
        status: :pending,
        price: @listing.buy_now_price
      )

      # end auction immediately (optional but practical)
      @listing.update!(auction_ends_at: Time.current)
    end

    redirect_to order_path(@listing.order), notice: t("flash.buy_now.success")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to listing_path(@listing), alert: e.record.errors.full_messages.first
  end
end
