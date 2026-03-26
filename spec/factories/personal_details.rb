FactoryBot.define do
  factory :personal_details do
    # first name sometimes resolves to 'Al' which is too short for a negative test
    first_name { "#{Faker::Name.initials}#{Faker::Name.first_name}" }
    last_name { Faker::Name.last_name.delete("'") }
    has_right_to_work_in_uk { true }
    completed_steps { { "name" => "completed", "work" => "completed" } }
    jobseeker_profile

    trait :not_started do
      first_name { nil }
      last_name { nil }
      completed_steps { {} }
    end
  end
end
