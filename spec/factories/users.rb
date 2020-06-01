FactoryBot.define do
  factory :user do
    oid { Faker::Crypto.md5 }
    accepted_terms_at { Time.zone.today - 5.months }
    email { Faker::Internet.email }
    dsi_data { {
      school_urns: proc {
        set = Set.new
        (0..4).to_a.sample.times {
          set.add(Faker::Number.number(digits: 6))
        }
        set
      }.call,
      school_group_uids: [Faker::Number.number(digits: [4, 5].sample), nil].sample
    } }
  end
end
