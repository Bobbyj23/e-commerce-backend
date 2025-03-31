FactoryBot.define do
    factory Product do
      name { Faker::Name.name }
      description { Faker::Lorem.sentence }
      price { Faker::Number.decimal(l_digits: 2) }
      association :category
    end

    trait :invalid_product do
      name { nil }
      description { nil }
      price { nil }
      association :category
    end
end
