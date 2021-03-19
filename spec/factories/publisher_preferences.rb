FactoryBot.define do
  factory :publisher_preference do
    association :organisation
    association :publisher
  end
end
