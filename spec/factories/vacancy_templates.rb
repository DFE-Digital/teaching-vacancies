FactoryBot.define do
  factory :vacancy_template do
    name { Faker::Book.title }

    # trait :teaching_role do
    #   job_roles { factory_rand(Vacancy::TEACHING_JOB_ROLES, 1) }
    # end
  end
end
