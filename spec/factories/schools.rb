FactoryBot.define do
  factory :school do
    association :school_type
    association :region

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

    trait :primary do
      phase { :primary }
    end

    trait :secondary do
      phase { :secondary }
    end

    trait :with_live_vacancies do
      after(:create) do |school, _evaluator|
        create_list(:vacancy, 2, :published, school: school)
      end
    end

    trait :with_expired_vacancies do
      after(:create) do |school, _evaluator|
        create_list(:vacancy, 2, :expired, school: school)
      end
    end
  end
end
