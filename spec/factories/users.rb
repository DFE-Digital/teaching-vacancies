FactoryBot.define do
  factory :user do
    accepted_terms_at { Time.zone.today - 5.months }
    dsi_data do
      {
        school_urns: proc {
          set = Set.new
          (0..4).to_a.sample.times do
            number = Faker::Number.number(digits: 6)
            set.add(number.to_s)
          end
          set
                     }.call,
        trust_uids: proc {
        number = Faker::Number.number(digits: [4, 5].sample)
        [[number.to_s, nil].sample]
                    }.call
      }
    end
    email { Faker::Internet.email }
    family_name { Faker::Name.last_name.gsub("'", '') }
    given_name { Faker::Name.first_name }
    oid { Faker::Crypto.md5 }
  end
end
