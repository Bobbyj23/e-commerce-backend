class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items, allow_destroy: true

  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending processing shipped delivered cancelled] }

  before_save :calculate_total

  def calculate_total
    self.total = order_items.sum { |item| item.price * item.quantity }
  end
end
