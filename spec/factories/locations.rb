FactoryBot.define do
  factory :job_preferences_location, class: JobPreferences::Location do
    association :job_preferences

    name { Faker::Address.city }
    radius { 5 }
  end
end
