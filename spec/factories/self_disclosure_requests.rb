FactoryBot.define do
  factory :self_disclosure_request do
    job_application
  end

  trait :sent do
    status { "sent" }

    after(:create, &:sent!)
  end

  trait :received do
    status { "received" }

    after(:create) do |request|
      request.sent!
      request.received!
    end
  end

  trait :manual do
    status { "manual" }

    after(:create, &:manual!)
  end
end
