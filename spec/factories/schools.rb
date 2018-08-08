FactoryBot.define do
  factory :school do
    detailed_school_type
    school_type
    region

    name { Faker::Educator.secondary_school.strip }
    description { Faker::Lorem.paragraph(1) }
    urn { Faker::Number.number(10) }
    address { Faker::Address.street_name }
    town { Faker::Address.city }
    county { Faker::Address.state_abbr }
    postcode { Faker::Address.postcode }
    phase { :secondary }
    easting { '1' }
    northing { '1' }
    regional_pay_band_area

    trait :primary do
      phase { :primary }
    end

    trait :secondary do
      phase { :secondary }
    end
  end
end
