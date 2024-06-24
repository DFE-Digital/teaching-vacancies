FactoryBot.define do
  factory :saved_job do
    association :jobseeker
    association :vacancy
  end
end
