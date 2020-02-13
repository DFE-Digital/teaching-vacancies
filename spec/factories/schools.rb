FactoryBot.define do
  factory :school do
    association :school_type
    association :region

    name { Faker::Educator.secondary_school.strip }
    description { Faker::Lorem.paragraph(sentence_count: 1) }
    urn { Faker::Number.number(digits: 10) }
    address { Faker::Address.street_name }
    town { Faker::Address.city }
    county { Faker::Address.state_abbr }
    local_authority { Faker::Address.state_abbr }
    postcode { Faker::Address.postcode }
    phase { :secondary }
    easting { '1' }
    northing { '1' }

    trait :nursery do
      phase { :nursery }
    end

    trait :primary do
      phase { :primary }
    end

    trait :secondary do
      phase { :secondary }
    end

    trait :in_london do
      association :region, name: 'London'
    end

    trait :outside_london do
      association :region, name: 'East of England'
    end
  end
end
