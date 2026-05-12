class Seller::CustomersController < Seller::BaseController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @customers = pagy(current_user.customers.order(:name), items: 20)
  end

  def show
    @orders = @customer.orders.recent.limit(10)
  end

  def new
    @customer = current_user.customers.build
  end

  def edit; end

  def create
    @customer = current_user.customers.build(customer_params)
    if @customer.save
      redirect_to seller_customer_path(@customer), notice: "Customer created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      redirect_to seller_customer_path(@customer), notice: "Customer updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.destroy
    redirect_to seller_customers_path, notice: "Customer deleted."
  end

  private

  def set_customer
    @customer = current_user.customers.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :address, :company_name, :notes, :active)
  end
end
