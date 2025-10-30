FactoryBot.define do
  factory :conversation do
    job_application

    archived { false }
  end
end
