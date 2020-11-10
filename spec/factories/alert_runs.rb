FactoryBot.define do
  factory :alert_run do
    association :subscription
    run_on { Date.current }
    job_id { "ABC123" }
  end
end
