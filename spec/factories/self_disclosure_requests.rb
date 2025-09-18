FactoryBot.define do
  factory :self_disclosure_request do
    job_application
  end

  trait :sent do
    status { "sent" }
  end

  trait :received do
    status { "received" }
  end

  trait :manual do
    status { "manual" }
  end
end
