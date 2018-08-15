FactoryBot.define do
  factory :user do
    oid { Faker::Crypto.md5 }
    accepted_terms_at { Time.zone.today - 5.months }
  end
end