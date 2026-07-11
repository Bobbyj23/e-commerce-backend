# frozen_string_literal: true

module Mutations
  class UpdateOrderStatus < BaseMutation
    argument :order_id, ID, required: true
    argument :status, Types::OrderStatusType, required: true

    field :order, Types::OrderType, null: true
    field :errors, [ String ], null: false

    def resolve(order_id:, status:)
      order = current_user.orders.find(order_id)
      authorize order, :update?

      if order.update(status: status)
        { order: order, errors: [] }
      else
        { order: nil, errors: order.errors.full_messages }
      end
    end
  end
end
