FactoryBot.define do
  factory :job_application do
    status { :draft }
  end

  trait :complete do
    application_data do
      { "first_name": "John" }
    end
  end
end
