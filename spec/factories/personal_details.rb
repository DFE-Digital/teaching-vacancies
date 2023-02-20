FactoryBot.define do
  factory :personal_details do
    first_name { "Frodo" }
    last_name { "Baggins" }
    phone_number_provided { true }
    phone_number { "07777777777" }
    completed_steps { { "name" => "completed", "phone_number" => "completed" } }
    jobseeker_profile
  end

  trait :not_started do
    first_name { nil }
    last_name { nil }
    phone_number_provided { nil }
    phone_number { nil }
    completed_steps { {} }
  end
end
