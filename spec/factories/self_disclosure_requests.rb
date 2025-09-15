FactoryBot.define do
  factory :self_disclosure_request do
    job_application
  end

  trait :requested do
    status { "requested" }

    after(:create, &:requested!)
  end

  trait :received do
    status { "received" }
  end

  trait :created do
    status { "created" }

    after(:create, &:created!)
  end
end
