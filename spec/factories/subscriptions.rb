FactoryBot.define do
  factory :subscription do
    email { Faker::Internet.email }
    frequency { %i[daily weekly].sample }
    search_criteria do
      { keyword: Faker::Lorem.word,
        location: Faker::Address.postcode,
        radius: "10",
        working_patterns: %w[full_time part_time],
        job_roles: %w[nqt_suitable],
        phases: %w[primary] }.to_json
    end

    factory :daily_subscription do
      frequency { :daily }
    end

    factory :weekly_subscription do
      frequency { :weekly }
    end
  end
end
