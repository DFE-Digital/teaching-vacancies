FactoryGirl.define do
  factory :leadership do
    title { Faker::Job.title }
  end
end
