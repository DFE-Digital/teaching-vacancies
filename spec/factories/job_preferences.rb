FactoryBot.define do
  factory :job_preferences do
    roles { Vacancy.job_roles.keys }
    phases { Vacancy.phases.keys }
    key_stages { key_stages_for_phases }
    subjects { SUBJECT_OPTIONS.map(&:first) }
    working_patterns { Vacancy.working_patterns.keys }
    working_pattern_details { "Strictly no Mondays" }
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
      locations { [build(:job_preferences_location, name: Faker::Address.postcode, radius: Faker::Number.between(from: 1, to: 200), job_preferences: instance)] }
    end

    trait :for_seed_data do
      working_patterns { factory_rand_sample(Vacancy.working_patterns.keys, 1..2) }
      roles { factory_rand_sample(Vacancy.job_roles.keys, 1..Vacancy.job_roles.keys.count) }
      phases { factory_rand_sample(Vacancy.phases.keys, 1..Vacancy.phases.keys.count) }
      subjects { factory_rand_sample(SUBJECT_OPTIONS.map(&:first), 1..3) }
    end

    trait :incomplete do
      builder_completed { false }
      completed_steps { {} }
      working_pattern_details { nil }
    end
  end
end
