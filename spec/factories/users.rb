FactoryBot.define do
  factory :user do
    accepted_terms_at { Time.zone.today - 5.months }
    dsi_data { {
      school_urns: proc {
        set = Set.new
        (0..4).to_a.sample.times {
          number = Faker::Number.number(digits: 6)
          set.add(number.to_s)
        }
        set
        }.call,
      school_group_uids: proc {
        number = Faker::Number.number(digits: [4, 5].sample)
        [[number.to_s, nil].sample]
        }.call
      } }
    email { Faker::Internet.email }
    oid { Faker::Crypto.md5 }
  end
end
