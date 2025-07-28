FactoryBot.define do
  factory :vacancy_analytics do
    vacancy
    referrer_counts { { "direct" => 1, "yahoo" => 12, "magic" => 8, "linkedin" => 15 } }
  end
end
