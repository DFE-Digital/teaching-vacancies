FactoryBot.define do
  factory :subscription do
    email { Faker::Internet.email }
    frequency { :daily }
    search_criteria { { keyword: Faker::Lorem.word }.to_json }

    factory :daily_subscription do
      frequency { :daily }
    end

    factory :weekly_subscription do
      frequency { :weekly }
    end
  end
end
