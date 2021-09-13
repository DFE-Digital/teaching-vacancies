FactoryBot.define do
  factory :reference do
    name { Faker::Name.name }
    job_title { Faker::Company.profession }
    organisation { Faker::Educator.secondary_school }
    relationship { "Line Manager" }
    email { Faker::Internet.email(domain: "example.com") }
    phone_number { "01234 567890" }

    job_application
  end
end
