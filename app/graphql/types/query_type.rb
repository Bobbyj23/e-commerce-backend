# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true, description: "Fetches a list of objects given a list of IDs." do
      argument :ids, [ ID ], required: true, description: "IDs of the objects."
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :products, [ Types::ProductType ], null: false
    field :product, Types::ProductType, null: false do
      argument :id, ID, required: true
    end

    field :categories, [ Types::CategoryType ], null: false
    field :category, Types::CategoryType, null: false do
      argument :id, ID, required: true
    end

    field :orders, [ Types::OrderType ], null: false
    field :order, Types::OrderType, null: false do
      argument :id, ID, required: true
    end

    def products
      policy_scope(Product)
    end

    def product(id:)
      product = Product.find(id)
      authorize product
      product
    end

    def categories
      policy_scope(Category)
    end

    def category(id:)
      category = Category.find(id)
      authorize category
      category
    end

    def orders
      policy_scope(Order)
    end

    def order(id:)
      current_user.orders.find(id)
    end
  end
end
