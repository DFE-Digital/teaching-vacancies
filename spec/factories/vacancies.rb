FactoryBot.define do
  factory :vacancy do
    association :min_pay_scale, factory: :pay_scale
    association :max_pay_scale, factory: :pay_scale
    association :subject
    association :leadership
    association :school
    association :document

    job_title { Faker::Lorem.sentence[1...30].strip }
    job_description { Faker::Lorem.paragraph(sentence_count: 4) }
    education { Faker::Lorem.paragraph(sentence_count: 4) }
    qualifications { Faker::Lorem.paragraph(sentence_count: 4) }
    experience { Faker::Lorem.paragraph(sentence_count: 4) }
    status { :published }
    working_patterns { ['full_time'] }
    expires_on { Faker::Time.forward(days: 14) }
    expiry_time { expires_on&.change(sec: 0) }
    publish_on { Time.zone.today }
    minimum_salary { SalaryValidator::MIN_SALARY_ALLOWED }
    maximum_salary { SalaryValidator::MAX_SALARY_LIMIT - 100 }
    contact_email { Faker::Internet.email }
    application_link { Faker::Internet.url }
    benefits { Faker::Lorem.sentence }
    newly_qualified_teacher { true }
    reference { SecureRandom.uuid }
    hired_status { nil }
    listed_elsewhere { nil }

    trait :fail_minimum_validation do
      job_title { Faker::Job.title[0..2] }
      job_description { Faker::Lorem.paragraph[0..5] }
      experience { Faker::Lorem.paragraph[0..7] }
      education { Faker::Lorem.paragraph[0..8] }
      qualifications { Faker::Lorem.paragraph[0...8] }
    end

    trait :fail_maximum_validation do
      job_title { Faker::Lorem.characters(number: 150) }
      job_description { Faker::Lorem.characters(number: 50001) }
      experience { Faker::Lorem.characters(number: 1010) }
      education { Faker::Lorem.characters(number: 1005) }
      qualifications { Faker::Lorem.characters(number: 1002) }
      minimum_salary { (SalaryValidator::MAX_SALARY_LIMIT + 100) }
      maximum_salary { SalaryValidator::MAX_SALARY_LIMIT + 100 }
    end

    trait :fail_minimum_salary_max_validation do
      minimum_salary { SalaryValidator::MAX_SALARY_LIMIT + 100 }
    end

    trait :fail_maximum_salary_max_validation do
      minimum_salary { SalaryValidator::MIN_SALARY_ALLOWED }
      maximum_salary { SalaryValidator::MAX_SALARY_LIMIT + 100 }
    end

    trait :complete do
      starts_on { Faker::Time.between(from: Time.zone.today + 10.days, to: Time.zone.today + 30.days) }
      ends_on { Faker::Time.between(from: Time.zone.today + 30.days, to: Time.zone.today + 60.days) }
      expires_on { Faker::Time.between(from: Time.zone.today + 2.days, to: Time.zone.today + 9.days) }
      publish_on { Faker::Time.between(from: Time.zone.today, to: Time.zone.today + 1.day) }
    end

    trait :draft do
      status { :draft }
    end

    trait :trashed do
      status { :trashed }
    end

    trait :published do
      status { :published }
      expires_on { Faker::Time.between(from: Time.zone.today + 10.days, to: Time.zone.today + 20.days) }
    end

    trait :published_slugged do
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
    end

    trait :expired do
      to_create { |instance| instance.save(validate: false) }
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
      publish_on { Faker::Time.between(from: Time.zone.today - 14.days, to: Time.zone.today - 7.days) }
      expires_on { Faker::Time.backward(days: 6) }
    end

    trait :future_publish do
      publish_on { Time.zone.today + 2.days }
      expires_on { Time.zone.today + 2.months }
    end

    trait :past_publish do
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
      publish_on { Time.zone.yesterday }
      expires_on { Time.zone.today + 2.months }
      starts_on { Time.zone.today + 3.months }
      ends_on { Time.zone.today + 4.months }
    end

    trait :job_schema do
      working_patterns { ['full_time', 'part_time'] }
      weekly_hours { '8.5' }
      education { Faker::Lorem.paragraph }
      benefits { Faker::Lorem.sentence }
    end

    trait :expire_tomorrow do
      expires_on { Time.zone.tomorrow.end_of_day }
    end

    trait :without_working_patterns do
      to_create { |instance| instance.save(validate: false) }
      sequence(:slug) { |n| "slug-#{n}" }
      working_patterns { nil }
    end

    trait :with_feedback do
      listed_elsewhere { :listed_paid }
      hired_status { :hired_tvs }
    end

    trait :with_no_expiry_time do
      status { :published }
      expires_on { Faker::Time.between(from: Time.zone.today + 10.days, to: Time.zone.today + 20.days) }
      expiry_time { nil }
    end

    trait :first_supporting_subject do
      association :first_supporting_subject, factory: :subject
    end

    trait :second_supporting_subject do
      association :second_supporting_subject, factory: :subject
    end
  end
end
