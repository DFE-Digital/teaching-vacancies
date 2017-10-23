FactoryGirl.define do
  factory :region do
    name { Faker::Lorem.unique.words }
  end
end
