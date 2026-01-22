class HomeController < ApplicationController
  def index
    @q = params[:q].to_s.strip
    @category_id = params[:category_id].to_s.strip
    @condition = params[:condition].to_s.strip
    @sort = params[:sort].presence || "newest"

    scope = Listing.published.includes(:category)

    scope = scope.where("title ILIKE ?", "%#{@q}%") if @q.present?
    scope = scope.where(category_id: @category_id) if @category_id.present?
    scope = scope.where(condition: @condition) if @condition.present?

    scope =
      case @sort
      when "price_asc" then scope.order(start_price: :asc)
      when "price_desc" then scope.order(start_price: :desc)
      else scope.order(published_at: :desc)
      end

    @categories = Category.ordered
    @conditions = Listing.where.not(condition: [nil, ""]).distinct.order(:condition).pluck(:condition)

    @listings = scope.page(params[:page]).per(8)
  end
end
