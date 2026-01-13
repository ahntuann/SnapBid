class Seller::ListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: %i[show edit update submit_ai_verification]

  def index
    @listings = current_user.listings.order(created_at: :desc)
  end

  def show
    @listing = Listing.find(params[:id])
  end

  def new
    @listing = current_user.listings.new
  end

  def create
    @listing = current_user.listings.new(listing_params)

    if @listing.save
      redirect_to seller_listing_path(@listing), notice: t("flash.listing.created")
    else
      flash.now[:alert] = t("errors.listing.invalid")
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @listing.update(listing_params)
      redirect_to seller_listing_path(@listing), notice: t("flash.listing.updated")
    else
      flash.now[:alert] = t("errors.listing.invalid")
      render :edit, status: :unprocessable_entity
    end
  end

  def submit_ai_verification
    AiAuthenticationService.verify_listing!(@listing)
    redirect_to seller_listing_path(@listing), notice: t("flash.ai.submitted")
  rescue => e
    redirect_to seller_listing_path(@listing), alert: t("flash.ai.error", message: e.message)
  end

  private

  def set_listing
    @listing = current_user.listings.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(:title, :category, :condition, :seller_note, images: [])
  end
end
