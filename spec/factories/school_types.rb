FactoryGirl.define do
  factory :school_type do
    label { Faker::Lorem.unique.sentence }
  end
end
