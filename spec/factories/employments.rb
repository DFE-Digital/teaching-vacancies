FactoryBot.define do
  factory :employment do
    organisation { Faker::Educator.secondary_school }
    job_title { "Teacher" }
    subjects { Faker::Educator.subject }
    main_duties { Faker::Lorem.paragraph(sentence_count: 2) }
    started_on { Faker::Date.in_date_period(year: 2016) }
    current_role { "no" }
    ended_on { Faker::Date.in_date_period(year: 2018) }

    job_application
  end

  trait :employment1 do
    organisation { "Townington Secondary School" }
    job_title { "KS3 Teaching Assistant" }
    main_duties { "Pastoral support for students. Managing student behaviour. Monitored students’ progress and gave feedback to teachers." }
  end

  trait :employment2 do
    organisation { "English Teacher" }
    job_title { "Sheffield Secondary School" }
    main_duties { "Planning and delivering English Literature and Language lessons ro a range of abilities across KS3 and GCSE to prepare them for exams. Contributing to the English department via extra curricular activities, organising trips, and running a reading club." }
  end

  trait :jobseeker_profile_employment do
    job_application { nil }

    jobseeker_profile
  end
end
