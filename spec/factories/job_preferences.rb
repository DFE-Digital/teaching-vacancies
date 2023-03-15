FactoryBot.define do
  factory :job_preferences do
    association :jobseeker_profile
  end
end
