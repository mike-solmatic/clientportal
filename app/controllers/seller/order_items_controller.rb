class Seller::OrderItemsController < Seller::BaseController
  before_action :set_order

  def create
    @order_item = @order.order_items.build(order_item_params)
    if @order_item.save
      redirect_to seller_order_path(@order), notice: "Item added."
    else
      redirect_to seller_order_path(@order), alert: @order_item.errors.full_messages.join(", ")
    end
  end

  def update
    @order_item = @order.order_items.find(params[:id])
    if @order_item.update(order_item_params)
      redirect_to seller_order_path(@order), notice: "Item updated."
    else
      redirect_to seller_order_path(@order), alert: @order_item.errors.full_messages.join(", ")
    end
  end

  def destroy
    @order_item = @order.order_items.find(params[:id])
    @order_item.destroy
    redirect_to seller_order_path(@order), notice: "Item removed."
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  end

  def order_item_params
    params.require(:order_item).permit(:product_id, :description, :quantity, :unit_price)
  end
end
