FactoryBot.define do
  factory :alert_run do
    association :subscription
    run_on { Time.zone.today }
    job_id { "ABC123" }
  end
end
