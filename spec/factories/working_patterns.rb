FactoryBot.define do
  factory :working_pattern do
    slug { 'full_time' }
    label { 'Full time' }

    trait(:full_time) {}

    trait :part_time do
      slug { 'part_time' }
      label { 'Part time' }
    end
  end
end
