class Seller::PaymentsController < Seller::BaseController
  before_action :set_order

  def new
    @payment = @order.payments.build(payment_date: Date.current)
  end

  def create
    @payment = @order.payments.build(payment_params)
    @payment.invoice = @order.invoice
    if @payment.save
      redirect_to seller_order_path(@order), notice: "Payment recorded successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @payment = @order.payments.find(params[:id])
    @payment.destroy
    redirect_to seller_order_path(@order), notice: "Payment removed."
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  end

  def payment_params
    params.require(:payment).permit(:amount, :payment_method, :status, :payment_date, :reference, :notes)
  end
end
