FactoryBot.define do
  factory :local_authority do
    code { Faker::Lorem.unique.words }
    name { Faker::Lorem.unique.words }
  end
end
