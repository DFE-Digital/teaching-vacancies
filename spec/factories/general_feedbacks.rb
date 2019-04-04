FactoryBot.define do
  factory :general_feedback do
    visit_purpose { 2 }
    rating { 1 }
    comment { 'Some feedback text' }
  end
end
