FactoryBot.define do
  factory :jobseeker do
    email { Faker::Internet.unique.email(domain: "contoso.com") }
    govuk_one_login_id { "urn:fdc:gov.uk:2022:#{SecureRandom.hex}" }

    trait :for_seed_data do
      current_sign_in_at { 5.months.ago + rand(7).days }
    end

    trait :email_opted_out do
      email_opt_out { true }
      email_opt_out_reason { 0 }
    end

    trait :with_closed_account do
      account_closed_on { Date.current - 1.week }
    end
  end
end
