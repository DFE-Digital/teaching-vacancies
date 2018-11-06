FactoryBot.define do
  factory :pay_scale do
    label { Faker::Lorem.unique.words(2).join(' ') }
    sequence(:code) { |n| "MPS#{n}" }
  end
end
