class SellersController < ApplicationController
  def show
    @seller = User.sellers.find(params[:id])
    public_listings = @seller.listings.where.not(published_at: nil)
    sold_listings = public_listings.joins(:order)
                                   .merge(Order.where.not(status: :cancelled))
    active_listings = public_listings.left_outer_joins(:order)
                                     .where(orders: { id: nil })

    @total_listings = public_listings.count
    @sold_count = sold_listings.count
    @active_count = active_listings.count

    @listing_tab = params[:tab].presence_in(%w[all sold active]) || "active"
    @listings = case @listing_tab
                when "sold"
                  sold_listings
                when "all"
                  public_listings
                else
                  active_listings
                end.order(published_at: :desc).distinct.page(params[:page]).per(12)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Người bán không tồn tại."
  end
end
