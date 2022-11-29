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
    main_duties { "Pastoral support for Year 7 students. Monitored students’ progress and gave feedback to teachers. Supported the teacher with behaviour management. Administrative duties, such as organising materials, and preparing and clearing up the classroom. Ran a daily homework club. First Aid trained." }
  end

  trait :employment2 do
    organisation { "English Teacher" }
    job_title { "Sheffield Secondary School" }
    main_duties { "Planning and delivering English Literature and Language lessons ro a range of abilities across KS3 and GCSE to prepare them for exams. Marking work, tracking development, and feeding back to students and parents. Managing student behaviour. Supervising teaching assistants. Contributing to the English department via extra curricular activities, organising trips, and running a reading club. Keeping up to date with subject knowledge, INSET training, and CPD." }
  end
end
