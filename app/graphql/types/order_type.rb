# frozen_string_literal: true

module Types
  class OrderType < Types::BaseObject
    field :id, ID, null: false
    field :status, Types::OrderStatusType, null: false
    field :total, Float, null: false
    field :user, Types::UserType, null: false
    field :order_items, [ Types::OrderItemType ], null: false
  end
end
