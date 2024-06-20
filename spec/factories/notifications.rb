FactoryBot.define do
  factory :notification do
    recipient { nil }
    type { "" }
    params { "" }
    read_at { "2021-04-15 18:28:16" }
  end

  trait :job_application_received do
    type { "Publishers::JobApplicationReceivedNotifier" }
    read_at { nil }
  end
end
