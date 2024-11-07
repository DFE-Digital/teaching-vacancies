FactoryBot.define do
  factory :jobseeker do
    email { Faker::Internet.unique.email(domain: "contoso.com") }
    confirmed_at { 1.hour.ago }
    govuk_one_login_id { "urn:fdc:gov.uk:2022:#{SecureRandom.hex}" }

    trait :with_profile do
      after(:create) do |jobseeker|
        create(:jobseeker_profile, jobseeker: jobseeker)
      end
    end
  end
end
