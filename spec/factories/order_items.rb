# update this factory to be correct so you can create an order item in your tests
FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    quantity { 1 }
  end
end
