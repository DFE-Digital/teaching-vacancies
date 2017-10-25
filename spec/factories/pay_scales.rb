FactoryGirl.define do
  factory :pay_scale do
    label { Faker::Lorem.unique.words(2) }
  end
end
