FactoryBot.define do
  factory :pay_scale do
    label { Faker::Lorem.unique.words(2).join(' ') }
    code { Faker::Code.asin }
    salary { Faker::Number.number(4) }
    starts_at { Time.zone.today - 5.months }
    expires_at { Time.zone.today + 5.months }
  end
end
