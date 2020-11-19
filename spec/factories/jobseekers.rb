FactoryBot.define do
  factory :jobseeker do
    email { Faker::Internet.email }
    password { "passw0rd" }
  end
end
