FactoryBot.define do
  OFSTED_RATINGS = ["Outstanding", "Good", "Requires Improvement", "Inadequate"]
  RELIGIOUS_CHARACTERS = ["Church of England", "Romanic Catholic", "None", "Does not apply"]
  RSC_REGIONS = [
    "North-West London and South-Central England",
    "South-East England and South London",
    "East of England and North-East London",
    "East Midlands and the Humber",
    "Lancashire and West Yorkshire",
    "North of England",
    "South West England",
    "West Midlands"
  ]

  factory :school do
    association :school_type
    association :region

    address { Faker::Address.street_name }
    county { Faker::Address.state_abbr }
    description { Faker::Lorem.paragraph(sentence_count: 1) }
    easting { '1' }
    gias_data { {
      close_date: nil,
      head_first_name: Faker::Name.first_name,
      head_last_name: Faker::Name.last_name,
      head_title: Faker::Name.prefix.gsub('.',''),
      last_ofsted_inspection_date: Faker::Date.between(from: 999.days.ago, to: 5.days.ago),
      number_of_pupils: Faker::Number.number(digits: 3),
      oftsed_rating: OFSTED_RATINGS.sample,
      open_date: Faker::Date.between(from: 10000.days.ago, to: 1000.days.ago),
      religious_character: RELIGIOUS_CHARACTERS.sample,
      rsc_region: RSC_REGIONS.sample,
      school_capacity: Faker::Number.number(digits: 4),
      telephone: Faker::Number.number(digits: 11).to_s,
      trust_name: Faker::Company.name + " Trust"
      } }
    local_authority { Faker::Address.state_abbr }
    name { Faker::Educator.secondary_school.strip }
    northing { '1' }
    phase { :secondary }
    postcode { Faker::Address.postcode }
    town { Faker::Address.city }
    urn { Faker::Number.number(digits: 6) }

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
