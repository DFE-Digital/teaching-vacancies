FactoryBot.define do
  factory :self_disclosure_request do
    job_application
    status { 2 }
  end
end
