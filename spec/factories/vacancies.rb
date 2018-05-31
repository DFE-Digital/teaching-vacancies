FactoryBot.define do
  factory :vacancy do
    association :min_pay_scale, factory: :pay_scale
    association :max_pay_scale, factory: :pay_scale
    association :subject
    association :leadership
    association :school

    job_title { Faker::Lorem.sentence[1...30].strip }
    working_pattern { :full_time }
    job_description { Faker::Lorem.paragraph(4) }
    education { Faker::Lorem.paragraph(4) }
    qualifications { Faker::Lorem.paragraph(4) }
    experience { Faker::Lorem.paragraph(4) }
    status { :published }
    expires_on { Faker::Time.forward(14) }
    publish_on { Time.zone.today }
    minimum_salary { SalaryValidator::MIN_SALARY_ALLOWED }
    maximum_salary { SalaryValidator::MAX_SALARY_ALLOWED }
    contact_email { Faker::Internet.email }
    application_link { Faker::Internet.url }
    weekly_hours '8.5'
    benefits { Faker::Lorem.sentence }

    trait :fail_minimum_validation do
      job_title { Faker::Job.title[0..2] }
      job_description { Faker::Lorem.paragraph[0..5] }
      experience { Faker::Lorem.paragraph[0..7] }
      education { Faker::Lorem.paragraph[0..8] }
      qualifications { Faker::Lorem.paragraph[0...8] }
    end

    trait :fail_maximum_validation do
      job_title { Faker::Lorem.characters(150) }
      job_description { Faker::Lorem.characters(50001) }
      experience { Faker::Lorem.characters(1010) }
      education { Faker::Lorem.characters(1005) }
      qualifications { Faker::Lorem.characters(1002) }
      minimum_salary { (SalaryValidator::MAX_SALARY_ALLOWED + 100) }
      maximum_salary { SalaryValidator::MAX_SALARY_ALLOWED + 100 }
    end

    trait :fail_minimum_salary_max_validation do
      minimum_salary { SalaryValidator::MAX_SALARY_ALLOWED + 100 }
    end

    trait :fail_maximum_salary_max_validation do
      minimum_salary { SalaryValidator::MIN_SALARY_ALLOWED }
      maximum_salary { SalaryValidator::MAX_SALARY_ALLOWED + 100 }
    end

    trait :complete do
      starts_on { Faker::Time.forward(30) }
      ends_on { Faker::Time.forward(60) }
      flexible_working true
    end

    trait :draft do
      status { :draft }
    end

    trait :trashed do
      status { :trashed }
    end

    trait :published do
      status { :published }
    end

    trait :expired do
      publish_on { Faker::Time.backward(14) }
      expires_on { Faker::Time.backward(7) }
    end

    trait :future_publish do
      publish_on { Time.zone.today + 2.days }
      expires_on { Time.zone.today + 2.months }
    end

    trait :job_schema do
      weekly_hours '8.5'
      education { Faker::Lorem.paragraph }
      benefits { Faker::Lorem.sentence }
    end
  end
end
