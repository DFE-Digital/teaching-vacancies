FactoryBot.define do
  factory :school_type do
    label { Faker::Lorem.unique.sentence.gsub('.', '').first(20) }
  end
end
