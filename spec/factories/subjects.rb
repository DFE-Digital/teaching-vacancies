FactoryGirl.define do
  factory :subject do
    name { Faker::Educator.course }
  end
end
