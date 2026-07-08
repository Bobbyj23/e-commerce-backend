class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items, allow_destroy: true

  STATUSES = %w[pending processing shipped delivered cancelled].freeze

  TRANSITIONS = {
    "pending" => %w[processing cancelled],
    "processing" => %w[shipped cancelled],
    "shipped" => %w[delivered],
    "delivered" => [],
    "cancelled" => []
  }.freeze

  attribute :status, :string, default: "pending"

  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validate :status_transition_must_be_allowed, on: :update, if: :status_changed?

  before_validation :calculate_total
  before_save :force_pending_status, if: :new_record?

  def calculate_total
    self.total = order_items.sum { |item| (item.price || item.product&.price || 0) * item.quantity.to_i }
  end

  private

  def force_pending_status
    self.status = "pending"
  end

  def status_transition_must_be_allowed
    allowed = TRANSITIONS.fetch(status_was, [])
    return if allowed.include?(status)

    errors.add(:status, "cannot transition from #{status_was} to #{status}")
  end
end
