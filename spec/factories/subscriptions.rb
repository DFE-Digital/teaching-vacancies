FactoryBot.define do
  factory :subscription do
    email { Faker::Internet.email(domain: "example.com") }
    frequency { factory_sample(%i[daily weekly]) }
    search_criteria do
      { keyword: Faker::Lorem.word,
        location: Faker::Address.postcode,
        radius: "10",
        working_patterns: %w[full_time part_time],
        job_roles: %w[ect_suitable],
        phases: %w[primary] }
    end
    active { true }

    factory :daily_subscription do
      frequency { :daily }
    end

    factory :weekly_subscription do
      frequency { :weekly }
    end
  end
end
