FactoryBot.define do
  factory :subscription do
    expires_on { Time.zone.today.strftime('%Y-%m-%d') }
    email { Faker::Internet.email }
    reference { Faker::Lorem.sentence }
    frequency { :daily }
    first_reminder_sent { false }
    final_reminder_sent { false }

    factory :daily_subscription do
      frequency { :daily }
      expires_on { 3.months.from_now }
    end
  end
end
