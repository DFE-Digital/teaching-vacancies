FactoryBot.define do
  factory :qualification_result do
    subject { Faker::Educator.subject }
    grade { factory_sample(%w[A B C D E F]) }
  end
end
