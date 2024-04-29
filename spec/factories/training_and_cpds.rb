FactoryBot.define do
  factory :training_and_cpd do
    name { "Rock climbing" }
    provider { "TeachTrainLtd" }
    grade { "Pass" }
    year_awarded { "2020" }

    jobseeker_profile
  end
end
