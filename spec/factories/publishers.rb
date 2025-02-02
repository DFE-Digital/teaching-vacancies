FactoryBot.define do
  factory :publisher do
    accepted_terms_at { Date.current - 5.months }
    acknowledged_candidate_profiles_interstitial { true }
    dismissed_new_features_page_at { Time.now }
    email { Faker::Internet.email(domain: "contoso.com") }
    family_name { Faker::Name.last_name.delete("'") }
    given_name { Faker::Name.first_name }
    oid { Faker::Crypto.md5 }

    trait :with_organisation do
      organisations { build_list(:school, 1) }
    end
  end
end
