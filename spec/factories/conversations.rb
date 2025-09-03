FactoryBot.define do
  factory :conversation do
    job_application
    title { "Regarding application: #{job_application.vacancy.job_title}" }
  end
end
