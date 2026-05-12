class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { seller: 0, admin: 1 }

  has_many :customers, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :products, dependent: :destroy

  validates :name, presence: true

  scope :active, -> { where(active: true) }
  scope :sellers, -> { where(role: :seller) }
  scope :admins, -> { where(role: :admin) }

  def display_name
    name.presence || email
  end
end
