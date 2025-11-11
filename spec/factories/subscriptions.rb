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
      subject { nil } # Legacy criteria
      organisation_slug { nil }
      newly_qualified_teacher { nil } # Legacy criteria
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
        subject: subject, # Legacy criteria
        organisation_slug: organisation_slug,
        newly_qualified_teacher: newly_qualified_teacher, # Legacy criteria
      }.delete_if { |_k, v| v.nil? }
    end

    trait :with_some_criteria do
      keyword { Faker::Adjective.positive }
      location { Faker::Address.postcode }
      radius { "10" }
      working_patterns { %w[full_time part_time] }
      teaching_job_roles { %w[teacher] }
      support_job_roles { %w[teaching_assistant it_support] }
      ect_statuses { %w[ect_suitable] }
      phases { %w[primary] }
    end

    trait :visa_sponsorship_required do
      visa_sponsorship_availability { %w[true] }
    end

    trait :ect_suitable do
      ect_statuses { %w[ect_suitable] }
    end

    trait :inactive do
      unsubscribed_at { Date.current }
    end

    trait :with_area_location do
      location { "London" }
      area { "POLYGON((0 0, 1 1, 0 1, 0 0))" }
      geopoint { nil }
      radius_in_metres { 16_090 } # 10 miles
    end

    trait :with_geopoint_location do
      area { nil }
      geopoint { "POINT(51.5074 -0.1278)" } # London
      radius_in_metres { 16_090 } # 10 miles
    end

    factory :daily_subscription do
      frequency { :daily }
    end

    factory :weekly_subscription do
      frequency { :weekly }
    end
  end
end
