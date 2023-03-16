FactoryBot.define do
  factory :job_preferences_location, class: JobPreferences::Location do
    name { Faker::Address.city }
    radius { 5 }

    association :job_preferences
  end
end
