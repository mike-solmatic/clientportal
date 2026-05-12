class Order < ApplicationRecord
  belongs_to :user
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_one :invoice, dependent: :destroy
  has_many :payments, dependent: :destroy

  accepts_nested_attributes_for :order_items, allow_destroy: true, reject_if: :all_blank

  enum :status, {
    draft: 0,
    pending: 1,
    confirmed: 2,
    paid: 3,
    cancelled: 4
  }

  validates :order_number, presence: true, uniqueness: { scope: :user_id }
  validates :customer, presence: true

  before_validation :generate_order_number, on: :create

  scope :today, -> { where(created_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :unpaid, -> { where(status: [:draft, :pending, :confirmed]) }
  scope :recent, -> { order(created_at: :desc) }

  def calculate_totals
    self.subtotal = order_items.sum(:total)
    self.tax = subtotal * 0.0
    self.total = subtotal + tax
  end

  def amount_paid
    payments.where(status: :completed).sum(:amount)
  end

  def amount_due
    total - amount_paid
  end

  def fully_paid?
    amount_due <= 0
  end

  private

  def generate_order_number
    return if order_number.present?
    last_order = user&.orders&.order(:created_at)&.last
    next_num = last_order ? last_order.order_number.gsub(/\D/, '').to_i + 1 : 1
    self.order_number = "ORD-#{Time.current.strftime('%Y%m')}-#{next_num.to_s.rjust(4, '0')}"
  end
end
