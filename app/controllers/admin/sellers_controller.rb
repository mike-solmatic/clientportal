class Admin::SellersController < Admin::BaseController
  before_action :set_seller, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    sellers = User.sellers.order(:name)
    sellers = sellers.where("name ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    @pagy, @sellers = pagy(sellers, items: 20)
  end

  def show
    @customers_count = @seller.customers.count
    @orders_count = @seller.orders.count
    @total_revenue = @seller.orders.where(status: :paid).sum(:total)
    @recent_orders = @seller.orders.recent.limit(10).includes(:customer)
    @monthly_stats = monthly_seller_stats(@seller)
  end

  def edit; end

  def update
    if @seller.update(seller_params)
      redirect_to admin_seller_path(@seller), notice: "Seller updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @seller.destroy
    redirect_to admin_sellers_path, notice: "Seller deleted."
  end

  def toggle_active
    @seller.update(active: !@seller.active)
    status = @seller.active? ? "activated" : "deactivated"
    redirect_to admin_sellers_path, notice: "Seller #{status}."
  end

  private

  def set_seller
    @seller = User.sellers.find(params[:id])
  end

  def seller_params
    params.require(:user).permit(:name, :email, :company_name, :phone, :active)
  end

  def monthly_seller_stats(seller)
    6.downto(0).map do |i|
      month = i.months.ago
      {
        month: month.strftime("%b %Y"),
        orders: seller.orders.where(created_at: month.beginning_of_month..month.end_of_month).count,
        revenue: seller.orders.where(status: :paid, created_at: month.beginning_of_month..month.end_of_month).sum(:total)
      }
    end
  end
end
