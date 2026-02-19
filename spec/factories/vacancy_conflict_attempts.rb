FactoryBot.define do
  factory :vacancy_conflict_attempt do
    publisher_ats_api_client
    conflicting_vacancy factory: %i[vacancy]
    attempts_count { 1 }
    first_attempted_at { Time.current }
    last_attempted_at { Time.current }

    trait :multiple_attempts do
      attempts_count { 3 }
      first_attempted_at { 3.days.ago }
      last_attempted_at { Time.current }
    end
  end
end
