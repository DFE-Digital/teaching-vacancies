FactoryBot.define do
  OFSTED_RATINGS = ['Outstanding', 'Good', 'Requires Improvement', 'Inadequate']
  RELIGIOUS_CHARACTERS = ['Church of England', 'Roman Catholic', 'None', 'Does not apply']

  factory :school do
    association :school_type
    association :region

    address { Faker::Address.street_name }
    county { Faker::Address.state_abbr }
    description { Faker::Lorem.paragraph(sentence_count: 1) }
    easting { '1' }
    gias_data { {
      "CloseDate": nil,
      "HeadFirstName": Faker::Name.first_name,
      "HeadLastName": Faker::Name.last_name,
      "HeadPreferredJobTitle": Faker::Name.prefix.gsub('.', ''),
      "DateOfLastInspectionVisit": Faker::Date.between(from: 999.days.ago, to: 5.days.ago),
      "NumberOfPupils": Faker::Number.number(digits: 3),
      "OfstedRating (name)": OFSTED_RATINGS.sample,
      "OpenDate": Faker::Date.between(from: 10000.days.ago, to: 1000.days.ago),
      "ReligiousCharacter (name)": RELIGIOUS_CHARACTERS.sample,
      "SchoolCapacity": Faker::Number.number(digits: 4),
      "TelephoneNum": Faker::Number.number(digits: 11).to_s,
      "Trusts (name)": Faker::Company.name + ' Trust'
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

  factory :academy, parent: :school do
     association :school_type, label: 'Academies'
  end
end
