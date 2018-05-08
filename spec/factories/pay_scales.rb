FactoryBot.define do
  factory :pay_scale do
    label { Faker::Lorem.unique.words(2).join(' ') }
    code { Faker::Code.asin }
    salary { Faker::Number.number(4) }
  end
end
