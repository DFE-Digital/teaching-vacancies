FactoryBot.define do
  factory :school_group do
    name { Faker::Company.name.gsub("'", '') }
  end

  factory :trust, parent: :school_group do
    address { Faker::Address.street_name.gsub("'", '') }
    county { Faker::Address.state_abbr }
    gias_data do
      {
        "Group UID": uid,
        "Group Name": name,
        "Group Type": 'Trust type',
        "Group Postcode": postcode,
        "Group Type (code)": '06',
        "Group Locality": address,
        "Group Town": town,
        "Group County": county
      }
    end
    name { Faker::Company.name.gsub("'", '') + ' Trust' }
    postcode { Faker::Address.postcode }
    town { Faker::Address.city.gsub("'", '') }
    uid { Faker::Number.number(digits: 5).to_s }
    website { Faker::Internet.url }
  end

  factory :local_authority, parent: :school_group do
    name { Faker::Address.state_abbr + ' LA' }
    local_authority_code { Faker::Number.number(digits: 3).to_s }
  end
end
