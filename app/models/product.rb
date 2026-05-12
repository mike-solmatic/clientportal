class Product < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :nullify

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
end
