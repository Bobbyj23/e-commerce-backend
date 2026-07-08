FactoryBot.define do
  factory :user do
    username { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
  end

  trait :invalid_user do
    username { nil }
    email { nil }
  end

  trait :admin do
    role { :admin }
  end
end
