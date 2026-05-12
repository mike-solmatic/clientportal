class Seller::InvoicesController < Seller::BaseController
  before_action :set_order
  before_action :set_invoice, only: [:show, :pdf]

  def show; end

  def new
    if @order.invoice
      redirect_to seller_order_invoice_path(@order), notice: "Invoice already exists."
    else
      @invoice = @order.build_invoice
    end
  end

  def create
    if @order.invoice
      redirect_to seller_order_invoice_path(@order), notice: "Invoice already exists."
      return
    end
    @invoice = @order.build_invoice(invoice_params)
    if @invoice.save
      redirect_to seller_order_invoice_path(@order), notice: "Invoice created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def pdf
    render pdf_response
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  end

  def set_invoice
    @invoice = @order.invoice
    redirect_to seller_order_path(@order), alert: "No invoice found." unless @invoice
  end

  def invoice_params
    params.require(:invoice).permit(:due_date, :notes, :status)
  end

  def pdf_response
    pdf_content = generate_invoice_pdf(@invoice)
    send_data pdf_content,
              filename: "#{@invoice.invoice_number}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end

  def generate_invoice_pdf(invoice)
    require "prawn"
    require "prawn/table"

    pdf = Prawn::Document.new
    pdf.text "INVOICE", size: 30, style: :bold
    pdf.move_down 10
    pdf.text "Invoice #: #{invoice.invoice_number}"
    pdf.text "Date: #{invoice.issued_date&.strftime('%B %d, %Y')}"
    pdf.text "Due: #{invoice.due_date&.strftime('%B %d, %Y')}"
    pdf.move_down 10

    order = invoice.order
    pdf.text "Bill To:", style: :bold
    pdf.text order.customer.name
    pdf.text order.customer.email if order.customer.email.present?
    pdf.text order.customer.phone if order.customer.phone.present?
    pdf.move_down 10

    table_data = [["Description", "Qty", "Unit Price", "Total"]]
    order.order_items.each do |item|
      table_data << [
        item.description,
        item.quantity.to_s,
        "$#{item.unit_price}",
        "$#{item.total}"
      ]
    end
    pdf.table(table_data, header: true, width: pdf.bounds.width)
    pdf.move_down 10
    pdf.text "Subtotal: $#{invoice.subtotal}", align: :right
    pdf.text "Tax: $#{invoice.tax}", align: :right
    pdf.text "Total: $#{invoice.total}", style: :bold, size: 14, align: :right
    pdf.render
  end
end
