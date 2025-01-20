FactoryBot.define do
  factory :professional_body_membership do
    name { "Teachers Union" }
    membership_type { "Platinum" }
    membership_number { "100" }
    date_membership_obtained { "2020" }
    exam_taken { "Yes" }

    jobseeker_profile { nil }
  end
end
