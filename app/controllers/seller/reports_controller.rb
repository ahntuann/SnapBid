class Seller::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller!

  def index
    @range = params[:range].presence_in(%w[7d 30d 90d all]) || "30d"
    @range_label = {
      "7d" => "7 ngày gần đây",
      "30d" => "30 ngày gần đây",
      "90d" => "90 ngày gần đây",
      "all" => "Toàn thời gian"
    }.fetch(@range)

    current_window = range_window(@range)
    previous_window = previous_window_for(current_window)

    current_snapshot = snapshot_for(current_window)
    previous_snapshot = previous_window ? snapshot_for(previous_window) : nil

    @published_count = current_snapshot[:published_count]
    @active_count = current_snapshot[:active_count]
    @sold_count = current_snapshot[:sold_count]
    @cancelled_count = current_snapshot[:cancelled_count]
    @sell_through_rate = current_snapshot[:sell_through_rate]
    @ending_soon_count = current_snapshot[:ending_soon_count]
    @gross_revenue = current_snapshot[:gross_revenue]
    @average_order_value = current_snapshot[:average_order_value]
    @paid_orders_count = current_snapshot[:paid_orders_count]
    @payment_completion_rate = current_snapshot[:payment_completion_rate]
    @top_categories = current_snapshot[:top_categories]
    @recent_orders = current_snapshot[:recent_orders]
    @recent_listings = current_snapshot[:recent_listings]

    @comparisons = {
      revenue: build_comparison(@gross_revenue, previous_snapshot&.dig(:gross_revenue), kind: :currency),
      average_order_value: build_comparison(@average_order_value, previous_snapshot&.dig(:average_order_value), kind: :currency),
      sell_through_rate: build_comparison(@sell_through_rate, previous_snapshot&.dig(:sell_through_rate), kind: :percent),
      payment_completion_rate: build_comparison(@payment_completion_rate, previous_snapshot&.dig(:payment_completion_rate), kind: :percent),
      sold_count: build_comparison(@sold_count, previous_snapshot&.dig(:sold_count), kind: :count),
      active_count: build_comparison(@active_count, previous_snapshot&.dig(:active_count), kind: :count)
    }

    @comparison_label = previous_window ? comparison_label_for(@range) : nil

    chart_window = chart_window_for(@range, current_window)
    chart_granularity = chart_granularity_for(@range)
    @revenue_series = build_order_series(chart_window, granularity: chart_granularity)
    @listing_creation_series = build_listing_series(chart_window, granularity: chart_granularity)
  end

  private

  def snapshot_for(window)
    scoped_listings = listings_scope(window)
    scoped_public_listings = scoped_listings.where.not(published_at: nil)
    scoped_sold_listings = scoped_public_listings.joins(:order)
                                                .merge(Order.where.not(status: :cancelled))
                                                .distinct
    scoped_active_listings = scoped_public_listings.left_outer_joins(:order)
                                                   .where(orders: { id: nil })
                                                   .distinct
    scoped_cancelled_listings = scoped_listings.joins(:order)
                                               .merge(Order.where(status: :cancelled))
                                               .distinct
    sold_orders = orders_scope(window).where.not(status: :cancelled)

    published_count = scoped_public_listings.count
    sold_count = scoped_sold_listings.count

    {
      published_count: published_count,
      active_count: scoped_active_listings.count,
      sold_count: sold_count,
      cancelled_count: scoped_cancelled_listings.count,
      sell_through_rate: published_count.zero? ? 0 : ((sold_count.to_f / published_count) * 100).round,
      ending_soon_count: scoped_active_listings.where(auction_ends_at: Time.current..24.hours.from_now).count,
      gross_revenue: sold_orders.sum("COALESCE(orders.total, orders.price)"),
      average_order_value: sold_orders.average("COALESCE(orders.total, orders.price)")&.to_d || 0,
      paid_orders_count: sold_orders.where(status: :paid).count,
      payment_completion_rate: sold_count.zero? ? 0 : ((sold_orders.where(status: :paid).count.to_f / sold_count) * 100).round,
      top_categories: scoped_public_listings
                        .left_joins(:category)
                        .group("categories.name")
                        .order(Arel.sql("COUNT(listings.id) DESC"))
                        .limit(5)
                        .count("listings.id")
                        .map { |name, count| [name.presence || "Chưa phân loại", count] },
      recent_orders: sold_orders.includes(:buyer, :listing).order(created_at: :desc).limit(8),
      recent_listings: scoped_listings.includes(:order, :category).order(created_at: :desc).limit(6)
    }
  end

  def listings_scope(window)
    scope = current_user.listings
    window ? scope.where(created_at: window) : scope
  end

  def orders_scope(window)
    scope = Order.joins(:listing).where(listings: { user_id: current_user.id })
    window ? scope.where(created_at: window) : scope
  end

  def range_window(range_key)
    return nil if range_key == "all"

    from_time = case range_key
                when "7d" then 7.days.ago
                when "90d" then 90.days.ago
                else 30.days.ago
                end

    from_time..Time.current
  end

  def previous_window_for(current_window)
    return nil unless current_window

    span = current_window.end - current_window.begin
    previous_end = current_window.begin
    previous_start = previous_end - span
    previous_start...previous_end
  end

  def comparison_label_for(range_key)
    case range_key
    when "7d" then "7 ngày trước"
    when "90d" then "90 ngày trước"
    else "30 ngày trước"
    end
  end

  def build_comparison(current_value, previous_value, kind: :count)
    previous = previous_value || 0
    current = current_value || 0
    delta = current.to_d - previous.to_d
    percent = previous.to_d.zero? ? nil : ((delta / previous.to_d) * 100).round

    {
      current: current,
      previous: previous,
      delta: delta,
      percent: percent,
      kind: kind,
      direction: delta <=> 0
    }
  end

  def chart_window_for(range_key, current_window)
    return 6.months.ago.beginning_of_month..Time.current if range_key == "all"

    current_window
  end

  def chart_granularity_for(range_key)
    case range_key
    when "90d" then :week
    when "all" then :month
    else :day
    end
  end

  def build_order_series(window, granularity:)
    buckets = initialize_buckets(window, granularity)

    orders_scope(window).where.not(status: :cancelled).each do |order|
      key = bucket_key(order.created_at, granularity)
      next unless buckets[key]

      buckets[key][:revenue] += order.total_price.to_d
      buckets[key][:orders] += 1
    end

    buckets.values.map do |bucket|
      {
        label: bucket[:label],
        revenue: bucket[:revenue].to_f,
        orders: bucket[:orders]
      }
    end
  end

  def build_listing_series(window, granularity:)
    buckets = initialize_buckets(window, granularity)

    listings_scope(window).each do |listing|
      key = bucket_key(listing.created_at, granularity)
      next unless buckets[key]

      buckets[key][:count] += 1
    end

    buckets.values.map do |bucket|
      {
        label: bucket[:label],
        count: bucket[:count]
      }
    end
  end

  def initialize_buckets(window, granularity)
    start_time = window.begin
    end_time = window.end
    buckets = {}

    cursor = case granularity
             when :month then start_time.beginning_of_month
             when :week then start_time.beginning_of_week(:monday)
             else start_time.beginning_of_day
             end

    while cursor <= end_time
      key = bucket_key(cursor, granularity)
      buckets[key] = {
        label: bucket_label(cursor, granularity),
        revenue: 0.to_d,
        orders: 0,
        count: 0
      }

      cursor = case granularity
               when :month then cursor.next_month
               when :week then cursor + 7.days
               else cursor + 1.day
               end
    end

    buckets
  end

  def bucket_key(time, granularity)
    case granularity
    when :month then time.beginning_of_month.to_date
    when :week then time.beginning_of_week(:monday).to_date
    else time.to_date
    end
  end

  def bucket_label(time, granularity)
    case granularity
    when :month then time.strftime("%m/%Y")
    when :week then "Tuần #{time.strftime('%d/%m')}"
    else time.strftime("%d/%m")
    end
  end

  def ensure_seller!
    redirect_to profile_path, alert: "Bạn chưa có gian hàng." unless current_user.seller?
  end
end