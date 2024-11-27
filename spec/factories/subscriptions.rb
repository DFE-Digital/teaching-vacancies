FactoryBot.define do
  factory :subscription do
    transient do
      keyword { nil }
      location { nil }
      radius { nil }
      working_patterns { nil }
      teaching_job_roles { nil }
      support_job_roles { nil }
      ect_statuses { nil }
      phases { nil }
      visa_sponsorship_availability { nil }
      subjects { nil }
      organisation_slug { nil }
    end

    email { Faker::Internet.email(domain: "contoso.com") }
    frequency { factory_sample(%i[daily weekly]) }
    search_criteria do
      {
        keyword: keyword,
        location: location,
        radius: radius,
        working_patterns: working_patterns,
        teaching_job_roles: teaching_job_roles,
        support_job_roles: support_job_roles,
        ect_statuses: ect_statuses,
        phases: phases,
        visa_sponsorship_availability: visa_sponsorship_availability,
        subjects: subjects,
        organisation_slug: organisation_slug,
      }.delete_if { |_k, v| v.nil? }
    end
    active { true }

    trait :with_some_criteria do
      keyword { Faker::Lorem.word }
      location { Faker::Address.postcode }
      radius { "10" }
      working_patterns { %w[full_time part_time] }
      teaching_job_roles { %w[teacher] }
      support_job_roles { %w[teaching_assistant it_support] }
      ect_statuses { %w[ect_suitable] }
      phases { %w[primary] }
    end

    trait :visa_sponsorship_required do
      visa_sponsorship_availability { ["true"] }
    end

    trait :ect_suitable do
      ect_statuses { ["ect_suitable"] }
    end

    factory :daily_subscription do
      frequency { :daily }
    end

    factory :weekly_subscription do
      frequency { :weekly }
    end
  end
end
