FactoryBot.define do
  factory :reference do
    name { Faker::Name.name }
    job_title { factory_sample(%w[Headteacher Teacher]) }
    organisation { Faker::Educator.secondary_school }
    relationship { factory_sample(["Line Manager", "Colleague", "Mentor"]) }
    email { Faker::Internet.email(domain: "example.com") }
    phone_number { "01234 567890" }
    created_at { Faker::Date.in_date_period(year: 2016) }

    job_application
  end
end
