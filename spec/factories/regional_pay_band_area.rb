FactoryBot.define do
  factory :regional_pay_band_area do
    name { Faker::Lorem.unique.words }

    after :create do |rpba|
      create(:pay_scale, regional_pay_band_area: rpba)
    end
  end
end
