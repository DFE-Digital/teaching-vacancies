FactoryBot.define do
  factory :note do
    content { Faker::Lorem.paragraph(sentence_count: 1) }
    association :job_application
    association :publisher
  end
end
