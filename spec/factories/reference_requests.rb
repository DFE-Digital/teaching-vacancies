FactoryBot.define do
  factory :reference_request do
    referee
    token { SecureRandom.uuid }
    status { :created }

    after(:stub) do |request|
      request.email = request.referee&.email
    end

    after(:build) do |request|
      request.email = request.referee&.email
    end
  end

  trait :reference_requested do
    status { :requested }
  end

  trait :reference_received do
    status { :received }
  end
end
