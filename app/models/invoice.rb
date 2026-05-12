class Invoice < ApplicationRecord
  belongs_to :order
  has_many :payments, dependent: :destroy

  enum :status, {
    draft: 0,
    sent: 1,
    paid: 2,
    overdue: 3,
    cancelled: 4
  }

  validates :invoice_number, presence: true, uniqueness: true

  before_validation :generate_invoice_number, on: :create
  before_validation :sync_from_order, on: :create

  scope :recent, -> { order(created_at: :desc) }
  scope :unpaid, -> { where(status: [:draft, :sent, :overdue]) }

  def amount_paid
    payments.where(status: :completed).sum(:amount)
  end

  def amount_due
    total - amount_paid
  end

  def overdue?
    due_date.present? && due_date < Date.current && !paid?
  end

  private

  def generate_invoice_number
    return if invoice_number.present?
    last = Invoice.order(:created_at).last
    next_num = last ? last.invoice_number.gsub(/\D/, '').to_i + 1 : 1
    self.invoice_number = "INV-#{Time.current.strftime('%Y%m')}-#{next_num.to_s.rjust(4, '0')}"
  end

  def sync_from_order
    return unless order
    self.subtotal ||= order.subtotal
    self.tax ||= order.tax
    self.total ||= order.total
    self.issued_date ||= Date.current
    self.due_date ||= Date.current + 30.days
  end
end
