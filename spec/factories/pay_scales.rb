FactoryBot.define do
  factory :pay_scale do
    label { Faker::Lorem.unique.words(number: 2).join(' ') }
    sequence(:code) { |n| "MPS#{n}" }
  end
end
