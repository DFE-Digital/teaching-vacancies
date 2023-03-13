FactoryBot.define do
  factory :jobseeker_profile do
    about_you { Faker::Lorem.paragraph(sentence_count: 2) }
    active { true }
    qualified_teacher_status { factory_sample(JobseekerProfile.qualified_teacher_statuses.keys) }
    qualified_teacher_status_year { "2000" if qualified_teacher_status == "yes" }

    jobseeker
    personal_details { build(:personal_details, jobseeker_profile: instance) }
    job_preferences { build :job_preferences, jobseeker_profile: instance }

    trait :with_qualifications do
      qualifications { [build(:qualification, jobseeker_profile: instance)] }
    end

    trait :with_employment_history do
      employments { [build(:employment, jobseeker_profile: instance)] }
    end
  end
end
