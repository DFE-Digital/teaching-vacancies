FactoryBot.define do
  factory :pay_scale do
    label { Faker::Lorem.unique.words(2).join(' ') }
    sequence(:code) { |n| "MPS#{n}" }
    salary { Faker::Number.between(26000, 27000) }
    starts_at { Time.zone.today - 5.months }
    expires_at { Time.zone.today + 5.months }
    regional_pay_band_area
    index { Faker::Number.between(2, 9) }
  end
end
