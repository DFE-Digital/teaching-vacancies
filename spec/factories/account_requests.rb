FactoryBot.define do
  factory :account_request do
    full_name { Faker::Name.last_name.delete("'") }
    email { Faker::Internet.email }
    organisation_name { Faker::Company.name }
    organisation_identifier { Faker::Number.number(digits: 3).to_s }
  end
end
