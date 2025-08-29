FactoryBot.define do
  factory :reference_request do
    referee
    token { SecureRandom.uuid }
    status { :created }
    email { Faker::Internet.email(domain: "contoso.com") }
    marked_as_complete { false }

    after(:stub) do |request|
      request.email = request.referee.email if request.referee
    end

    after(:build) do |request|
      request.email = request.referee.email if request.referee
    end
  end

  trait :reference_requested do
    status { :requested }
  end

  trait :reference_received do
    status { :received }
  end
end
