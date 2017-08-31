FactoryGirl.define do
  factory :school do
    association :school_type

    name { Faker::Company.name }
    description { Faker::Lorem.paragraph(1) }
    urn { Faker::Number.number(10) }
    address { Faker::Address.street_name }
    town { Faker::Address.city }
    county { Faker::Address.state }
    postcode { Faker::Address.postcode }
  end
end