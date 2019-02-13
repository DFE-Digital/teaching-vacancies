FactoryBot.define do
  factory :alert_run do
    association :subscription
    run_on
    job_id
  end
end
