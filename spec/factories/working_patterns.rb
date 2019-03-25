FactoryBot.define do
  factory :working_pattern do
    labels = ['Full time', 'Part time', 'Job share']

    label { labels.sample }

    trait :full_time do
      label { labels[0] }
    end

    trait :part_time do
      label { labels[1] }
    end

    trait :job_share do
      label { labels[2] }
    end
  end
end
