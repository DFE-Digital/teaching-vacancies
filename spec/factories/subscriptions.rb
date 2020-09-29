FactoryBot.define do
  factory :subscription do
    email { Faker::Internet.email }
    reference { Faker::Lorem.sentence }
    frequency { :daily }

    factory :daily_subscription do
      frequency { :daily }
    end

    factory :weekly_subscription do
      frequency { :weekly }
    end
  end
end
