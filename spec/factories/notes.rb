FactoryBot.define do
  factory :note do
    content { Faker::Lorem.paragraph(sentence_count: 1) }
    job_application
    publisher
  end
end
