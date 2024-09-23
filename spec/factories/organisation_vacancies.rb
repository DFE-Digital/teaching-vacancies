FactoryBot.define do
  factory :organisation_vacancy do
    association(:organisation)
    association(:vacancy)
  end
end
