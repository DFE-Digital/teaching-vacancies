FactoryBot.define do
  factory :school_group do
    name { Faker::Company.name.delete("'") }
  end

  factory :trust, parent: :school_group do
    address { Faker::Address.street_name.delete("'") }
    county { Faker::Address.state_abbr }
    description { Faker::Lorem.paragraph(sentence_count: 1) }
    email { Faker::Internet.email }
    gias_data do
      {
        "Group UID": uid,
        "Group Name": name,
        "Group Type": "Trust type",
        "Group Postcode": postcode,
        "Group Type (code)": "06",
        "Group Locality": address,
        "Group Town": town,
        "Group County": county,
      }
    end
    group_type { "Multi-academy trust" }
    name { "#{Faker::Company.name.delete("'")} Trust" }
    postcode { Faker::Address.postcode }
    safeguarding_information { Faker::Lorem.paragraph(sentence_count: 1) }
    sequence(:slug) { |n| "#{name.parameterize}-#{n}" }
    town { Faker::Address.city.delete("'") }
    uid { Faker::Number.number(digits: 5).to_s }
    url { Faker::Internet.url(host: "example.com") }

    trait :profile_incomplete do
      description { nil }
    end
  end

  factory :local_authority, parent: :school_group do
    name { "#{Faker::Address.state_abbr} LA" }
    group_type { "local_authority" }
    local_authority_code { Faker::Number.number(digits: 3).to_s }
    safeguarding_information { Faker::Lorem.paragraph(sentence_count: 1) }
  end
end
