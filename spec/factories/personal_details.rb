FactoryBot.define do
  factory :personal_details do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name.delete("'") }
    phone_number_provided { true }
    phone_number { "07777777777" }
    completed_steps { { "name" => "completed", "phone_number" => "completed" } }
    jobseeker_profile

    trait :not_started do
      first_name { nil }
      last_name { nil }
      phone_number_provided { nil }
      phone_number { nil }
      completed_steps { {} }
    end
  end
end
