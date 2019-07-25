FactoryBot.define do
  factory :general_feedback do
    visit_purpose { :find_teaching_job }
    comment { 'Some feedback text' }
  end
end
