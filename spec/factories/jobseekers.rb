FactoryBot.define do
  factory :jobseeker do
    email { Faker::Internet.unique.email(domain: "example.com") }
    password { "passw0rd" }
    confirmed_at { 1.hour.ago }

    trait :with_profile do
      after(:create) do |jobseeker|
        create(:jobseeker_profile, jobseeker: jobseeker)
      end
    end
  end
end
