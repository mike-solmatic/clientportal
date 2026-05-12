class Seller::OrdersController < Seller::BaseController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :confirm, :cancel]

  def index
    orders = current_user.orders.includes(:customer).recent
    orders = orders.where(status: params[:status]) if params[:status].present?
    @pagy, @orders = pagy(orders, items: 20)
    @status_counts = {
      all: current_user.orders.count,
      draft: current_user.orders.draft.count,
      pending: current_user.orders.pending.count,
      confirmed: current_user.orders.confirmed.count,
      paid: current_user.orders.paid.count,
      cancelled: current_user.orders.cancelled.count
    }
  end

  def show
    @order_items = @order.order_items.includes(:product)
    @payments = @order.payments
    @invoice = @order.invoice
  end

  def new
    @order = current_user.orders.build
    @order.order_items.build
    @customers = current_user.customers.active.order(:name)
  end

  def edit
    @order.order_items.build if @order.order_items.empty?
    @customers = current_user.customers.active.order(:name)
  end

  def create
    @order = current_user.orders.build(order_params)
    if @order.save
      redirect_to seller_order_path(@order), notice: "Order created successfully."
    else
      @customers = current_user.customers.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      redirect_to seller_order_path(@order), notice: "Order updated successfully."
    else
      @customers = current_user.customers.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    redirect_to seller_orders_path, notice: "Order deleted."
  end

  def confirm
    @order.confirmed!
    redirect_to seller_order_path(@order), notice: "Order confirmed."
  end

  def cancel
    @order.cancelled!
    redirect_to seller_order_path(@order), notice: "Order cancelled."
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :customer_id, :status, :notes, :due_date,
      order_items_attributes: [:id, :product_id, :description, :quantity, :unit_price, :_destroy]
    )
  end
end
