FactoryBot.define do
  factory :personal_details do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.html_safe_last_name }
    has_right_to_work_in_uk { true }
    jobseeker_profile

    trait :not_started do
      first_name { nil }
      last_name { nil }
    end
  end
end
