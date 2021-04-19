FactoryBot.define do
  factory :employment do
    organisation { Faker::Educator.secondary_school }
    job_title { "Teacher" }
    salary { "Pay scale level 3" }
    subjects { Faker::Educator.subject }
    main_duties { Faker::Lorem.paragraph(sentence_count: 2) }
    started_on { Faker::Date.in_date_period(year: 2016) }
    current_role { "no" }
    ended_on { Faker::Date.in_date_period(year: 2018) }

    job_application
  end
end
