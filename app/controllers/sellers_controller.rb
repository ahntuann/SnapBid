class SellersController < ApplicationController
  def show
    @seller = User.sellers.find(params[:id])
    @published_listings = @seller.listings
                                  .where.not(published_at: nil)
                                  .order(published_at: :desc)
                                  .page(params[:page]).per(12)

    @total_listings = @seller.listings.count
    @sold_count     = @seller.listings.joins(:order)
                              .merge(Order.where.not(status: :cancelled)).count
    @active_count   = @seller.listings
                              .where.not(published_at: nil)
                              .left_outer_joins(:order)
                              .where(orders: { id: nil }).count
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Người bán không tồn tại."
  end
end
