FactoryBot.define do
  factory :vacancy_analytics do
    vacancy
    referrer_counts { { "Direct" => 1, "Yahoo" => 12, "Ask Jeeves" => 18, "Magic" => 8, "LinkedIn" => 15 } }
  end
end
