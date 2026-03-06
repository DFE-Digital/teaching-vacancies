FactoryBot.define do
  factory :employment do
    organisation { Faker::Educator.secondary_school }
    job_title { "Teacher" }
    subjects { Faker::Educator.subject }
    main_duties { Faker::Lorem.paragraph(sentence_count: 2) }
    reason_for_leaving { Faker::Lorem.paragraph(sentence_count: 1) }
    started_on { Date.new(2016, 1, 1) }
    ended_on { date.new(2018, 12, 31) }
    employment_type { :job }

    job_application
  end

  trait :for_seed_data do
    started_on { Faker::Date.in_date_period(year: 2016) }
    ended_on { Faker::Date.in_date_period(year: 2018) }
  end

  trait :break do
    employment_type { :break }
  end

  trait :jobseeker_profile_employment do
    job_application { nil }

    jobseeker_profile
  end

  trait :current_role do
    is_current_role { true }
    ended_on { nil }
  end
end
