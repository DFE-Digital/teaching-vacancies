FactoryBot.define do
  ofsted_ratings = ["Outstanding", "Good", "Requires Improvement", "Inadequate"].freeze

  factory :school do
    # make default inside the U.K.
    geopoint { "POINT(-1 51.5)" }

    address { Faker::Address.street_name.delete("'") }
    county { Faker::Address.state_abbr }
    description { Faker::Lorem.paragraph(sentence_count: 1) }
    email { Faker::Internet.email(domain: "contoso.com") }
    establishment_status { "Open" }

    gias_data do
      {
        CloseDate: nil,
        HeadFirstName: Faker::Name.first_name,
        HeadLastName: Faker::Name.last_name.delete("'"),
        HeadPreferredJobTitle: Faker::Name.prefix.delete("."),
        DateOfLastInspectionVisit: Faker::Date.between(from: 999.days.ago, to: 5.days.ago),
        NumberOfPupils: Faker::Number.number(digits: 3),
        "OfstedRating (name)": factory_sample(ofsted_ratings),
        OpenDate: Faker::Date.between(from: 10_000.days.ago, to: 1000.days.ago),
        SchoolCapacity: Faker::Number.number(digits: 4),
        TelephoneNum: Faker::Number.number(digits: 11).to_s,
        "Trusts (name)": "#{Faker::Company.name.delete("'")} Trust",
        "TypeOfEstablishment (code)": "02",
      }
    end
    detailed_school_type { "Voluntary aided school" }
    minimum_age { 11 }
    maximum_age { 18 }
    sequence(:name) { |n| "#{Faker::Educator.secondary_school.strip.delete("'")} #{n}" }
    phase { :secondary }
    region { "South-East England" }
    safeguarding_information { Faker::Lorem.paragraph(sentence_count: 1) }
    sequence(:slug) { |n| "#{name.parameterize}-#{n}" }
    school_type { "LA maintained school" }
    postcode { Faker::Address.postcode }
    town { Faker::Address.city.delete("'") }
    # URN is validated unique for a school
    sequence(:urn) { |n| n + 100_000 }
    url { Faker::Internet.url(host: "example.com") }

    after(:build) do |org|
      if org.uk_geopoint.nil? && org.geopoint.present?
        org.uk_geopoint = if org.geopoint.is_a?(String)
                            GeoFactories.convert_wgs84_to_sr27700(GeoFactories::FACTORY_4326.parse_wkt(org.geopoint))
                          else
                            GeoFactories.convert_wgs84_to_sr27700(org.geopoint)
                          end
      end
    end

    after(:stub) do |org|
      if org.uk_geopoint.nil? && org.geopoint.present?
        org.uk_geopoint = if org.geopoint.is_a?(String)
                            GeoFactories.convert_wgs84_to_sr27700(GeoFactories::FACTORY_4326.parse_wkt(org.geopoint))
                          else
                            GeoFactories.convert_wgs84_to_sr27700(org.geopoint)
                          end
      end
    end

    trait :with_image do
      after(:build) do |school|
        blank_image = File.open(Rails.root.join("spec/fixtures/files/blank_image.png"))
        normalised_logo = ImageManipulator.new(image_file_path: blank_image.path).alter_dimensions_and_preserve_aspect_ratio("100", "100")

        school.logo.attach(io: StringIO.open(normalised_logo.to_blob), filename: "logo.png", content_type: "image/png")
        school.photo.attach(io: blank_image, filename: "photo.png", content_type: "image/png")
      end
    end

    after(:build) do |org|
      if org.uk_geopoint.nil? && org.geopoint.present?
        org.uk_geopoint = if org.geopoint.is_a?(String)
                            GeoFactories.convert_wgs84_to_sr27700(GeoFactories::FACTORY_4326.parse_wkt(org.geopoint))
                          else
                            GeoFactories.convert_wgs84_to_sr27700(org.geopoint)
                          end
      end
    end

    trait :closed do
      establishment_status { "Closed" }
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
          "OfstedRating (name)": factory_sample(ofsted_ratings),
          OpenDate: Faker::Date.between(from: 10_000.days.ago, to: 1000.days.ago),
          "ReligiousCharacter (name)": "Roman Catholic",
          SchoolCapacity: Faker::Number.number(digits: 4),
          TelephoneNum: Faker::Number.number(digits: 11).to_s,
          "Trusts (name)": "#{Faker::Company.name.delete("'")} Trust",
        }
      end
    end

    trait :no_geolocation do
      geopoint { nil }
    end

    trait :profile_incomplete do
      description { nil }
    end
  end

  factory :academy, parent: :school do
    school_type { "Academy" }
  end
end
