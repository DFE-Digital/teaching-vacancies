FactoryGirl.define do
  factory :subject do
    name { Faker::Educator.course }
    initialize_with { Subject.find_or_create_by(name: name) }
  end
end
