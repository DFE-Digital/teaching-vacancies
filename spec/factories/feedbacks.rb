FactoryBot.define do
  factory :feedback do
    feedback_type { :general }
    visit_purpose { :find_teaching_job }
    comment { "Some feedback text" }
    user_participation_response { :uninterested }
  end
end
