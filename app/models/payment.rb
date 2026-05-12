class Payment < ApplicationRecord
  belongs_to :order
  belongs_to :invoice, optional: true

  enum :payment_method, {
    cash: 0,
    bank_transfer: 1,
    credit_card: 2,
    check: 3,
    other: 4
  }

  enum :status, {
    pending: 0,
    completed: 1,
    failed: 2,
    refunded: 3
  }

  validates :amount, numericality: { greater_than: 0 }
  validates :payment_date, presence: true

  after_save :update_order_status
  after_destroy :update_order_status

  private

  def update_order_status
    return unless order
    if order.amount_due <= 0
      order.update_column(:status, Order.statuses[:paid])
    end
  end
end
