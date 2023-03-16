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

    locations { build_list(:job_preferences_location, 1, radius: 200, job_preferences: nil) }
    jobseeker_profile
  end
end
