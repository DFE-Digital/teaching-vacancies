FactoryBot.define do
  factory :subscription do
    email { Faker::Internet.email }
    frequency { :daily }

    factory :daily_subscription do
      frequency { :daily }
    end

    factory :weekly_subscription do
      frequency { :weekly }
    end
  end
end
