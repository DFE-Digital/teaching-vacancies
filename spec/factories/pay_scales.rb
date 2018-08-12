FactoryBot.define do
  factory :pay_scale do
    label { Faker::Lorem.unique.words(2).join(' ') }
    sequence(:code) { |n| "#{Faker::Code.nric}#{n}" }
    salary { Faker::Number.between(26000, 27000) }
    starts_at { Time.zone.today - 5.months }
    expires_at { Faker::Date.between(3.months.from_now, 9.months.from_now) }
    regional_pay_band_area
    index { Faker::Number.between(2, 43) }
  end
end
