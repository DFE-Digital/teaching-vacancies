FactoryBot.define do
  factory :vacancy_publish_feedback do
    rating { 1 }
    comment { "Some feedback text" }
    vacancy
    user
    user_participation_response { :not_interested }
    email { nil }

    trait :old_with_no_user do
      to_create { |instance| instance.save(validate: false) }
      user { nil }
    end
  end
end
