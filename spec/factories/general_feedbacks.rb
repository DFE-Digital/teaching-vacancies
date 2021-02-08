FactoryBot.define do
  factory :feedback do
    visit_purpose { :find_teaching_job }
    comment { "Some feedback text" }
    user_participation_response { :uninterested }
    email { nil }
  end
end
