FactoryBot.define do
  factory :subject do
    name { Faker::Educator.course_name }
    initialize_with { Subject.find_or_create_by(name: name) }
  end
end
