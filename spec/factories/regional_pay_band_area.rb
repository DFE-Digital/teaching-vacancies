FactoryBot.define do
  factory :regional_pay_band_area do
    name { Faker::Lorem.unique.words }
  end
end
