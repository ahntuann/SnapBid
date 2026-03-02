class WatchlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing

  def create
    @watchlist = current_user.watchlists.find_or_create_by!(listing: @listing)
    
    respond_to do |format|
      format.html { redirect_to @listing, notice: "Đã thêm vào danh sách theo dõi." }
      format.turbo_stream
    end
  end

  def destroy
    @watchlist = current_user.watchlists.find_by(listing: @listing)
    @watchlist&.destroy
    
    respond_to do |format|
      format.html { redirect_to @listing, notice: "Đã xóa khỏi danh sách theo dõi." }
      format.turbo_stream
    end
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end
end
