FactoryBot.define do
  factory :school do
    association :school_type
    association :region

    name { Faker::Educator.secondary_school.strip }
    description { Faker::Lorem.paragraph(sentence_count: 1) }
    urn { Faker::Number.number(digits: 6) }
    address { Faker::Address.street_name }
    town { Faker::Address.city }
    county { Faker::Address.state_abbr }
    local_authority { Faker::Address.state_abbr }
    postcode { Faker::Address.postcode }
    phase { :secondary }
    easting { '1' }
    northing { '1' }
    status { 'Open' }
    trust_name { 'Fake Trust' }
    number_of_pupils { Faker::Number.number(digits: 3) }
    head_title { 'Ms' }
    head_first_name { 'Helen' }
    head_last_name { 'Pluckrose' }
    religious_character { 'Church of England' }
    rsc_region { '?' }
    telephone { Faker::Number.number(digits: 11).to_s }
    open_date { Faker::Date.between(from: 100.days.ago, to: 10.days.ago) }
    close_date { nil }
    last_ofsted_inspection_date { Faker::Date.between(from: 9.days.ago, to: 5.days.ago) }
    oftsed_rating { 'Outstanding' }

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
