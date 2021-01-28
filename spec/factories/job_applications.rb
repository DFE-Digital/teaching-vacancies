FactoryBot.define do
  factory :job_application do
    status { :draft }
    jobseeker
    vacancy
  end

  trait :complete do
    application_data do
      { "first_name": "John" }
    end
  end
end
