FactoryBot.define do
  factory :expired_vacancy_feedback do
    listed_elsewhere { 1 }
    hired_status { 1 }
    vacancy
    user
  end
end
