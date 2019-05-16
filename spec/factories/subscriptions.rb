FactoryBot.define do
  factory :subscription do
    expires_on { Time.zone.today.strftime('%Y-%m-%d') }
    email { Faker::Internet.email }
    reference { Faker::Lorem.sentence }
    frequency { :daily }
    search_criteria do
      {
        location: 'EC1A 1AA',
        radius: 20,
        working_pattern: 'full_time',
        phases: ['primary', 'secondary']
      }.to_json
    end

    factory :daily_subscription do
      frequency { :daily }
      expires_on { 3.months.from_now }
    end
  end
end
