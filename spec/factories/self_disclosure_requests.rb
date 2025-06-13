FactoryBot.define do
  factory :self_disclosure_request do
    job_application
    status { "sent" }
  end

  trait :sent do
    status { "sent" }
  end

  trait :manual do
    status { "manual" }
  end
end
