# update this factory to be correct so you can create an order in your tests
FactoryBot.define do
  factory :order do
    association :user
    status { "pending" }
    total { 9.99 }

    after(:create) do |order|
     order.order_items = create_list(:order_item, 1, order: order)
    end
  end
end
