FactoryBot.define do
  factory :reference_request do
    referee
    token { SecureRandom.uuid }
    status { :requested }
    email { Faker::Internet.email(domain: "contoso.com") }
    marked_as_complete { false }

    after(:stub) do |request|
      request.email = request.referee.email if request.referee
    end

    after(:build) do |request|
      request.email = request.referee.email if request.referee
    end
  end

  trait :not_sent do
    status { :created }
  end

  trait :reference_received do
    status { :received }
  end
end
