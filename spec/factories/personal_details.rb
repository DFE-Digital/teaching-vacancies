FactoryBot.define do
  factory :personal_details do
    # Prevent first names like 'Al' causing false negatives
    first_name { Faker::Name.first_name.rjust(5, "abcd") }
    last_name { FFaker::Name.html_safe_last_name }
    has_right_to_work_in_uk { true }
    jobseeker_profile

    trait :not_started do
      first_name { nil }
      last_name { nil }
    end
  end
end
