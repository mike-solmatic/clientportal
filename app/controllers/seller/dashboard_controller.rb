class Seller::DashboardController < Seller::BaseController
  def index
    @orders_today = current_user.orders.today.count
    @unpaid_orders = current_user.orders.unpaid
    @unpaid_orders_count = @unpaid_orders.count
    @unpaid_total = @unpaid_orders.sum(:total)
    @recent_orders = current_user.orders.recent.limit(10).includes(:customer)
    @customers_count = current_user.customers.active.count
    @total_revenue = current_user.orders.where(status: :paid).sum(:total)
    @monthly_revenue = current_user.orders.where(status: :paid)
                                   .where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
                                   .sum(:total)
    @top_customers = current_user.customers.active
                                 .joins(:orders)
                                 .where(orders: { status: :paid })
                                 .group("customers.id")
                                 .select("customers.*, SUM(orders.total) as total_spent")
                                 .order("total_spent DESC")
                                 .limit(5)
  end
end
