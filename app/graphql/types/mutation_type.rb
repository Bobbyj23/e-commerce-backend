# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :update_order_status, mutation: Mutations::UpdateOrderStatus
  end
end
