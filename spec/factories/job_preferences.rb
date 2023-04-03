FactoryBot.define do
  factory :job_preferences do
    roles { factory_rand_sample(Vacancy.job_roles.keys, 1..Vacancy.job_roles.keys.count) }
    phases { factory_rand_sample(Vacancy.phases.keys, 1..Vacancy.phases.keys.count) }
    key_stages { key_stages_for_phases }
    subjects { factory_rand_sample(SUBJECT_OPTIONS.map(&:first), 1..3) }
    working_patterns { factory_rand_sample(%w[full_time part_time], 1..2) }
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
