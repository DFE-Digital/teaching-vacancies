FactoryBot.define do
  factory :employment do
    organisation { Faker::Educator.secondary_school }
    job_title { "Teacher" }
    subjects { Faker::Educator.subject }
    main_duties { Faker::Lorem.paragraph(sentence_count: 2) }
    reason_for_leaving { Faker::Lorem.paragraph(sentence_count: 1) }
    started_on { Faker::Date.in_date_period(year: 2016) }
    current_role { "no" }
    is_current_role { false }
    ended_on { Faker::Date.in_date_period(year: 2018) }
    employment_type { :job }

    job_application
  end

  trait :jobseeker_profile_employment do
    job_application { nil }

    jobseeker_profile
  end

  trait :current_role do
    current_role { "yes" }
    is_current_role { true }
    ended_on { nil }
  end
end
