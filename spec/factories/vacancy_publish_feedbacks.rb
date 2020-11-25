FactoryBot.define do
  factory :vacancy_publish_feedback do
    rating { 1 }
    comment { "Some feedback text" }
    vacancy
    publisher
    user_participation_response { :not_interested }
    email { nil }

    trait :old_with_no_publisher do
      to_create { |instance| instance.save(validate: false) }
      publisher { nil }
    end
  end
end
