FactoryBot.define do
  factory :job_preferences do
    roles { ["senior_leader"] }
    phases { ["nursery"] }
    key_stages { ["early_years"] }
    subjects { ["maths"] }
    working_patterns { ["full_time"] }
    builder_completed { true }
    completed_steps do
      {
        roles: "completed",
        phases: "completed",
        key_stages: "completed",
        subjects: "completed",
        working_patterns: "completed",
        locations: "completed",
      }
    end

    association :jobseeker_profile

    trait :with_locations do
      locations { [build(:job_preferences_locations, name: Faker::Address.postcode, radius: Faker::Number.between(from: 1, to: 200), jobseeker_profile: instance)] }
    end
  end
end
