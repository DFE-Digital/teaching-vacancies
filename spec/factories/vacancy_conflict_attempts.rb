FactoryBot.define do
  factory :vacancy_conflict_attempt do
    association :publisher_ats_api_client
    association :conflicting_vacancy, factory: :vacancy
    conflict_type { "external_reference" }
    attempts_count { 1 }
    first_attempted_at { Time.current }
    last_attempted_at { Time.current }

    trait :duplicate_content do
      conflict_type { "duplicate_content" }
    end

    trait :multiple_attempts do
      attempts_count { 3 }
      first_attempted_at { 3.days.ago }
      last_attempted_at { Time.current }
    end
  end
end
