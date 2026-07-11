# frozen_string_literal: true

module Sources
  class OrderItemsForOrder < GraphQL::Dataloader::Source
    def fetch(order_ids)
      items_by_order = OrderItem.where(order_id: order_ids).group_by(&:order_id)
      order_ids.map { |id| items_by_order[id] || [] }
    end
  end
end
