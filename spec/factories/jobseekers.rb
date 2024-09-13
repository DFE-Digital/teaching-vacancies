FactoryBot.define do
  factory :jobseeker do
    email { Faker::Internet.unique.email(domain: TEST_EMAIL_DOMAIN) }
    password { "passw0rd" }
    confirmed_at { 1.hour.ago }
  end
end
