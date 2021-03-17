FactoryBot.define do
  factory :publisher do
    accepted_terms_at { Date.current - 5.months }
    email { Faker::Internet.email }
    family_name { Faker::Name.last_name.delete("'") }
    given_name { Faker::Name.first_name }
    oid { Faker::Crypto.md5 }
  end
end
