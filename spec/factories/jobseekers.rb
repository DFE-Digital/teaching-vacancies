FactoryBot.define do
  factory :jobseeker do
    email { Faker::Internet.email }
    password { "passw0rd" }
    confirmed_at { 1.hour.ago }
  end
end
