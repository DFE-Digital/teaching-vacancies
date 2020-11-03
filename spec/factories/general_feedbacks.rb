FactoryBot.define do
  factory :general_feedback do
    visit_purpose { :find_teaching_job }
    comment { "Some feedback text" }
    user_participation_response { :not_interested }
    email { nil }
  end
end
