FactoryBot.define do
  factory :jobseeker do
    email { Faker::Internet.unique.email(domain: "contoso.com") }
    govuk_one_login_id { "urn:fdc:gov.uk:2022:#{SecureRandom.hex}" }

    trait :with_profile do
      after(:create) do |jobseeker|
        create(:jobseeker_profile, jobseeker: jobseeker)
      end
    end

    trait :email_opted_out do
      email_opt_out { true }
      email_opt_out_reason { 0 }
    end
  end
end
