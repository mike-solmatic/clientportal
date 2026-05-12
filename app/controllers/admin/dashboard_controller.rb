class Admin::DashboardController < Admin::BaseController
  def index
    @total_sellers = User.sellers.count
    @active_sellers = User.sellers.active.count
    @total_customers = Customer.count
    @total_orders = Order.count
    @total_revenue = Order.where(status: :paid).sum(:total)
    @monthly_revenue = Order.where(status: :paid)
                            .where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
                            .sum(:total)
    @orders_today = Order.today.count
    @unpaid_orders_count = Order.unpaid.count

    @top_sellers = User.sellers.active
                       .joins(:orders)
                       .where(orders: { status: :paid })
                       .group("users.id")
                       .select("users.*, COUNT(orders.id) as orders_count, SUM(orders.total) as total_revenue")
                       .order("total_revenue DESC")
                       .limit(10)

    @recent_sellers = User.sellers.order(created_at: :desc).limit(5)

    @monthly_stats = monthly_order_stats
  end

  private

  def monthly_order_stats
    6.downto(0).map do |i|
      month = i.months.ago
      {
        month: month.strftime("%b %Y"),
        orders: Order.where(created_at: month.beginning_of_month..month.end_of_month).count,
        revenue: Order.where(status: :paid, created_at: month.beginning_of_month..month.end_of_month).sum(:total)
      }
    end
  end
end
