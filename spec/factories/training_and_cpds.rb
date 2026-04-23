FactoryBot.define do
  factory :training_and_cpd do
    name { "Rock climbing" }
    provider { "TeachTrainLtd" }
    grade { "Pass" }
    year_awarded { "2020" }
    course_length { "1 year" }

    job_application { nil }
  end
end
