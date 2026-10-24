FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "テストユーザー#{n}" }
    sequence(:email) { |n| Faker::Internet.email(name: "user#{n}", domain: "example.com") }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
