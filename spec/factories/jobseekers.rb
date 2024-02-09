FactoryBot.define do
  factory :jobseeker do
    email { Faker::Internet.unique.email(domain: "example.com") }
    password { "passw0rd" }
    account_type { "teacher" }
    confirmed_at { 1.hour.ago }
  end
end
