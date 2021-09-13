FactoryBot.define do
  factory :jobseeker do
    email { Faker::Internet.email(domain: "example.com") }
    password { "passw0rd" }
    confirmed_at { 1.hour.ago }
  end
end
