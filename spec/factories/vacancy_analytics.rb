FactoryBot.define do
  factory :vacancy_analytics do
    vacancy
    referrer_counts { {} }
  end
end
