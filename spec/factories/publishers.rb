FactoryBot.define do
  factory :publisher do
    accepted_terms_at { Date.current - 5.months }
    dismissed_new_features_page_at { 2.days.ago }
    email { Faker::Internet.email(domain: "example.com") }
    family_name { Faker::Name.last_name.delete("'") }
    given_name { Faker::Name.first_name }
    oid { Faker::Crypto.md5 }
    viewed_new_features_page_at { 2.days.ago }
    viewed_application_feature_reminder_page_at { 2.days.ago }
  end
end
