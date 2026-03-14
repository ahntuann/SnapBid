class HomeController < ApplicationController
  # Hardcoded browse tabs: label => DB category names to match
  BROWSE_CATEGORIES = [
    { key: "tat_ca",   label: "Tất cả",   icon: "bi-grid-fill",        names: nil },
    { key: "giay",     label: "Giày",      icon: "bi-boot-fill",         names: %w[Giày Dép] },
    { key: "quan_ao",  label: "Quần áo",   icon: "bi-person-standing-dress", names: ["Áo", "Quần", "Quần áo", "Váy"] },
    { key: "tui_xach", label: "Túi xách",  icon: "bi-handbag-fill",      names: ["Túi xách", "Túi"] },
    { key: "vi",       label: "Ví",        icon: "bi-wallet2",           names: ["Ví", "Bóp"] },
    { key: "mu",       label: "Mũ",        icon: "bi-cone-striped",      names: ["Mũ", "Nón"] },
  ].freeze

  def index
    @q              = params[:q].to_s.strip
    @cat_key        = params[:cat_key].to_s.strip     # for browse tabs
    @condition_simple = params[:condition_simple].to_s.strip  # new / used
    @price_min      = params[:price_min].to_s.strip.presence
    @price_max      = params[:price_max].to_s.strip.presence
    @sort           = params[:sort].presence || "newest"

    @browse_categories = BROWSE_CATEGORIES
    @active_browse = BROWSE_CATEGORIES.find { |c| c[:key] == @cat_key } || BROWSE_CATEGORIES.first

    scope = Listing.published.includes(:category)

    scope = scope.where("title ILIKE ?", "%#{@q}%") if @q.present?

    # Filter by browse tab (category name match)
    if @active_browse[:names].present?
      scope = scope.joins(:category).where(categories: { name: @active_browse[:names] })
    end

    # Condition filter
    case @condition_simple
    when "new"
      scope = scope.where(condition: "new")
    when "used"
      scope = scope.where(condition: %w[like_new good fair])
    end

    # Price range
    scope = scope.where("start_price >= ?", @price_min.to_d) if @price_min.present?
    scope = scope.where("start_price <= ?", @price_max.to_d) if @price_max.present?

    scope =
      case @sort
      when "ending_soon"
        scope.reorder(Arel.sql("auction_ends_at ASC NULLS LAST"))
             .where("auction_ends_at > ?", Time.current)
      when "price_asc"
        scope.reorder(Arel.sql("COALESCE(start_price, 0) ASC"))
      when "price_desc"
        scope.reorder(Arel.sql("COALESCE(start_price, 0) DESC"))
      else
        scope.reorder(published_at: :desc)
      end

    # Category counts for browse tabs (unscoped to avoid ORDER BY conflict in PG GROUP BY)
    counts_by_name = Listing.unscoped
                             .where.not(published_at: nil)
                             .joins(:category)
                             .group("categories.name")
                             .count
    @browse_counts = BROWSE_CATEGORIES.each_with_object({}) do |cat, h|
      h[cat[:key]] = cat[:names].present? ? cat[:names].sum { |n| counts_by_name[n].to_i } : Listing.unscoped.where.not(published_at: nil).count
    end

    @conditions = Listing::CONDITIONS
    @listings = scope.page(params[:page]).per(12)

    # Additional sections at the bottom
    @daily_discoveries = Listing.published.order(Arel.sql('RANDOM()')).limit(12)
    @you_may_like = Listing.published.order(Arel.sql('RANDOM()')).limit(12)
  end
end
