FactoryBot.define do
  factory :jobseeker_profile do
    about_you { Faker::Lorem.paragraph(sentence_count: 2) }
    qualified_teacher_status { factory_sample(JobseekerProfile.qualified_teacher_statuses.keys) }

    jobseeker

    after(:build) do |jobseeker_profile|
      jobseeker_profile.qualified_teacher_status_year { "2000" } if jobseeker_profile.qualified_teacher_status == "yes"
    end
  end
end
