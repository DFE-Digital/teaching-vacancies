FactoryBot.define do
  factory :vacancy_template do
    name { Faker::Book.title }
  end
end
