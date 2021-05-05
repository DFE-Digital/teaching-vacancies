FactoryBot.define do
  factory :qualification_result do
    subject { Faker::Educator.subject }
    grade { %w[A B C D E F].sample }
  end
end
