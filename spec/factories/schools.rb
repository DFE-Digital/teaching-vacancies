FactoryBot.define do
  ofsted_ratings = ["Outstanding", "Good", "Requires Improvement", "Inadequate"].freeze
  religious_characters = ["Church of England", "Roman Catholic", "None", "Does not apply"].freeze

  factory :school do
    address { Faker::Address.street_name.delete("'") }
    county { Faker::Address.state_abbr }
    description { Faker::Lorem.paragraph(sentence_count: 1) }
    establishment_status { "Open" }
    geolocation { [1, 2] }
    geopoint { "POINT(2 1)" }
    gias_data do
      {
        CloseDate: nil,
        HeadFirstName: Faker::Name.first_name,
        HeadLastName: Faker::Name.last_name.delete("'"),
        HeadPreferredJobTitle: Faker::Name.prefix.delete("."),
        DateOfLastInspectionVisit: Faker::Date.between(from: 999.days.ago, to: 5.days.ago),
        NumberOfPupils: Faker::Number.number(digits: 3),
        "OfstedRating (name)": ofsted_ratings.sample,
        OpenDate: Faker::Date.between(from: 10_000.days.ago, to: 1000.days.ago),
        "ReligiousCharacter (name)": religious_characters.sample,
        SchoolCapacity: Faker::Number.number(digits: 4),
        TelephoneNum: Faker::Number.number(digits: 11).to_s,
        "Trusts (name)": "#{Faker::Company.name.delete("'")} Trust",
      }
    end
    minimum_age { 11 }
    maximum_age { 18 }
    name { Faker::Educator.secondary_school.strip.delete("'") }
    phase { :secondary }
    readable_phases { %w[secondary] }
    region { "South-East England" }
    school_type { "LA maintained school" }
    postcode { Faker::Address.postcode }
    town { Faker::Address.city.delete("'") }
    urn { Faker::Number.number(digits: 6) }
    url { Faker::Internet.url(host: "example.com") }

    trait :closed do
      establishment_status { "Closed" }
    end

    trait :nursery do
      phase { :nursery }
      readable_phases { %w[nursery] }
    end

    trait :primary do
      phase { :primary }
      readable_phases { %w[primary] }
    end

    trait :secondary do
      phase { :secondary }
      readable_phases { %w[secondary] }
    end

    trait :in_london do
      association :region, name: "London"
    end

    trait :outside_london do
      association :region, name: "East of England"
    end

    trait :catholic do
      gias_data do
        {
          CloseDate: nil,
          HeadFirstName: Faker::Name.first_name,
          HeadLastName: Faker::Name.last_name.delete("'"),
          HeadPreferredJobTitle: Faker::Name.prefix.delete("."),
          DateOfLastInspectionVisit: Faker::Date.between(from: 999.days.ago, to: 5.days.ago),
          NumberOfPupils: Faker::Number.number(digits: 3),
          "OfstedRating (name)": ofsted_ratings.sample,
          OpenDate: Faker::Date.between(from: 10_000.days.ago, to: 1000.days.ago),
          "ReligiousCharacter (name)": "Roman Catholic",
          SchoolCapacity: Faker::Number.number(digits: 4),
          TelephoneNum: Faker::Number.number(digits: 11).to_s,
          "Trusts (name)": "#{Faker::Company.name.delete("'")} Trust",
        }
      end
    end

    trait :no_geolocation do
      geolocation { nil }
      geopoint { nil }
    end
  end

  factory :academy, parent: :school do
    school_type { "Academy" }
  end
end
