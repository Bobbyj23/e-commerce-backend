# frozen_string_literal: true

module Types
  class OrderItemType < Types::BaseObject
    field :id, ID, null: false
    field :quantity, Integer, null: false
    field :price, Float, null: false
    field :product, Types::ProductType, null: false

    def product
      dataloader.with(Sources::RecordLoader, Product).load(object.product_id)
    end
  end
end
