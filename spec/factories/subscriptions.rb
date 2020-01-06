FactoryBot.define do
  factory :subscription do
    email { Faker::Internet.email }
    reference { Faker::Lorem.sentence }
    frequency { :daily }

    factory :daily_subscription do
      frequency { :daily }
    end
  end
end
