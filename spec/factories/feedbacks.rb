FactoryBot.define do
  factory :feedback do
    feedback_type { :general }
    visit_purpose { :find_teaching_job }
    rating { :highly_satisfied }
    comment { "Some feedback text" }
    user_participation_response { :uninterested }
  end
end
