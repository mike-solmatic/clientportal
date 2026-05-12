class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :description, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  before_save :calculate_total
  after_save :update_order_totals
  after_destroy :update_order_totals

  private

  def calculate_total
    self.total = (quantity || 0) * (unit_price || 0)
  end

  def update_order_totals
    order.calculate_totals
    order.save(validate: false)
  end
end
