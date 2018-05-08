FactoryBot.define do
  factory :leadership do
    title { Faker::Job.title }
    initialize_with { Leadership.find_or_create_by(title: title) }
  end
end
