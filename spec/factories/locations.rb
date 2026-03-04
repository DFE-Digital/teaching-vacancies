FactoryBot.define do
  factory :job_preferences_location, class: "JobPreferences::Location" do
    # want to avoid the within_uk validation when creating location job preferences
    # as it adds noise by querying Google to check uk-presence
    to_create { |instance| instance.save!(validate: false) }
    name { FFaker::AddressUK.city }
    radius { [0, 1, 5, 10, 15, 20, 25, 50, 100, 200].sample }

    association :job_preferences
  end
end
