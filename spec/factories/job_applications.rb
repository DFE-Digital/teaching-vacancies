FactoryBot.define do
  factory :job_application do
    status { :draft }
    completed_steps { [] }
    application_data { {} }
    jobseeker
    vacancy
  end

  trait :complete do
    application_data do
      { first_name: "John" }
    end
    completed_steps { JobApplication.completed_steps.keys }
  end
end
