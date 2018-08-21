FactoryBot.define do
  factory :detailed_school_type do
    label { Faker::Lorem.unique.sentence }
  end
end
