FactoryGirl.define do
  factory :leadership do
    title { Faker::Job.unique.title }
  end
end
