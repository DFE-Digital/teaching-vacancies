FactoryBot.define do
  factory :referee do
    name { Faker::Name.name }
    job_title { factory_sample(%w[Headteacher Teacher]) }
    organisation { Faker::Educator.secondary_school }
    relationship { factory_sample(["Line Manager", "Colleague", "Mentor"]) }
    # Can't use TEST_EMAIL_DOMAIN as factories are used by seeds to populate review apps
    email { Faker::Internet.email(domain: "contoso.com") }
    phone_number { Faker::PhoneNumber.phone_number }
    is_most_recent_employer { true }

    job_application
  end
end
