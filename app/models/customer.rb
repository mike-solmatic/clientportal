class Customer < ApplicationRecord
  belongs_to :user
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :active, -> { where(active: true) }

  def total_orders
    orders.count
  end

  def total_spent
    orders.where(status: :paid).sum(:total)
  end
end
