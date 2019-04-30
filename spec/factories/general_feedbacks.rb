FactoryBot.define do
  factory :general_feedback do
    visit_purpose { :find_teaching_job }
    rating { 1 }
    comment { 'Some feedback text' }
  end
end
