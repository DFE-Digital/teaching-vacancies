FactoryBot.define do
  factory :job_preferences_location, class: "JobPreferences::Location" do
    name { Faker::Address.city }
    radius { [0, 1, 5, 10, 15, 20, 25, 50, 100, 200].sample }

    association :job_preferences
  end
end
