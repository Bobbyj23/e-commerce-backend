class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :product, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_price

  private

  def set_price
    self.price = product.price if product
  end
end
