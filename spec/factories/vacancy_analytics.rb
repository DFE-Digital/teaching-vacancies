FactoryBot.define do
  factory :vacancy_analytics do
    vacancy
    referrer_counts { { "direct" => 1, "yahoo.com" => 12, "askjeeves.co.uk" => 18, "magic.co.uk" => 8, "linkedin.com" => 15 } }
  end
end
