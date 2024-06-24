FactoryBot.define do
  factory :reference do
    name { Faker::Name.name }
    job_title { factory_sample(%w[Headteacher Teacher]) }
    organisation { Faker::Educator.secondary_school }
    relationship { factory_sample(["Line Manager", "Colleague", "Mentor"]) }
    email { Faker::Internet.email(domain: "example.com") }
    phone_number { "01234 567890" }
    created_at { Faker::Date.in_date_period(year: 2016) }

    association :job_application
  end

  trait :reference1 do
    name { "Laura Davison" }
    organisation { "Townington Secondary School" }
    relationship { "Line manager" }
    email { "l.davison@english.townington.ac.uk" }
  end

  trait :reference2 do
    name { "John Thompson" }
    organisation { "Sheffield Secondary School" }
    relationship { "Line manager" }
    email { "john.thompson@english.sheffield.ac.uk" }
  end
end
