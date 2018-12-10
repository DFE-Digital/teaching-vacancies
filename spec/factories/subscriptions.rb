FactoryBot.define do
  factory :subscription do
    expires_on { Time.zone.today.strftime('%Y-%m-%d') }
    email { Faker::Internet.email }
  end
end
