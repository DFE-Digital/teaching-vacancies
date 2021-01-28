FactoryBot.define do
  factory :job_application_detail do
    details_type { "reference" }
    data { { name: "Jim" } }
    job_application
  end
end
