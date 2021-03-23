FactoryBot.define do
  factory :vacancy do
    after :create do |vacancy|
      create_list :document, 3, vacancy: vacancy
    end

    job_location { "at_one_school" }
    about_school { Faker::Lorem.paragraph(sentence_count: 4) }
    application_link { Faker::Internet.url(host: "example.com") }
    apply_through_teaching_vacancies { "yes" }
    benefits { Faker::Lorem.paragraph(sentence_count: 4) }
    contact_email { Faker::Internet.email }
    contact_number { "01234 123456" }
    contract_type { :fixed_term }
    contract_type_duration { "6 months" }
    education { Faker::Lorem.paragraph(sentence_count: 4) }
    experience { Faker::Lorem.paragraph(sentence_count: 4) }
    expires_on { Faker::Time.forward(days: 14) }
    expires_at { expires_on&.change(sec: 0) }
    hired_status { nil }
    how_to_apply { Faker::Lorem.paragraph(sentence_count: 4) }
    job_summary { Faker::Lorem.paragraph(sentence_count: 4) }
    job_roles { [:teacher] }
    job_title { Faker::Lorem.sentence[1...30].strip }
    listed_elsewhere { nil }
    personal_statement_guidance { Faker::Lorem.paragraph(sentence_count: 4) }
    publish_on { Date.current }
    qualifications { Faker::Lorem.paragraph(sentence_count: 4) }
    salary { Faker::Lorem.sentence[1...30].strip }
    school_visits { Faker::Lorem.paragraph(sentence_count: 4) }
    state { "create" }
    starts_on { Date.current + 1.year }
    status { :published }
    subjects { SUBJECT_OPTIONS.sample(2).map(&:first).sort! }
    suitable_for_nqt { "no" }
    working_patterns { %w[full_time] }

    trait :central_office do
      job_location { "central_office" }
      readable_job_location { I18n.t("publishers.organisations.readable_job_location.central_office") }
    end

    trait :at_one_school do
      job_location { "at_one_school" }
      readable_job_location { Faker::Educator.secondary_school.strip.delete("'") }
    end

    trait :at_multiple_schools do
      job_location { "at_multiple_schools" }
      readable_job_location { "More than one school (3)" }
    end

    trait :fail_minimum_validation do
      education { Faker::Lorem.paragraph[0..8] }
      experience { Faker::Lorem.paragraph[0..7] }
      job_summary { Faker::Lorem.paragraph[0..5] }
      job_title { Faker::Job.title[0..2] }
      qualifications { Faker::Lorem.paragraph[0...8] }
    end

    trait :fail_maximum_validation do
      education { Faker::Lorem.characters(number: 1005) }
      experience { Faker::Lorem.characters(number: 1010) }
      job_summary { Faker::Lorem.characters(number: 50_001) }
      job_title { Faker::Lorem.characters(number: 150) }
      salary { Faker::Lorem.characters(number: 257) }
      qualifications { Faker::Lorem.characters(number: 1002) }
    end

    trait :complete do
      starts_on { Faker::Time.between(from: Date.current + 10.days, to: Date.current + 30.days) }
      expires_on { Faker::Time.between(from: Date.current + 2.days, to: Date.current + 9.days) }
      publish_on { Faker::Time.between(from: Date.current, to: Date.current + 1.day) }
    end

    trait :starts_asap do
      starts_on { nil }
      starts_asap { true }
    end

    trait :draft do
      status { :draft }
    end

    trait :trashed do
      status { :trashed }
    end

    trait :published do
      status { :published }
      expires_on { Faker::Time.between(from: Date.current + 10.days, to: Date.current + 20.days) }
    end

    trait :published_slugged do
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
    end

    trait :expired do
      to_create { |instance| instance.save(validate: false) }
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
      publish_on { Faker::Time.between(from: Date.current - 14.days, to: Date.current - 7.days) }
      expires_on { Faker::Time.backward(days: 6) }
      expires_at { Faker::Time.backward(days: 6) }
    end

    trait :future_publish do
      publish_on { Date.current + 2.days }
      expires_on { Date.current + 2.months }
    end

    trait :past_publish do
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
      publish_on { Time.zone.yesterday }
      expires_on { Date.current + 2.months }
      starts_on { Date.current + 3.months }
    end

    trait :job_schema do
      working_patterns { %w[full_time part_time] }
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

    trait :suitable_for_nqt do
      suitable_for_nqt { "yes" }
      job_roles { %w[nqt_suitable] }
    end

    trait :not_suitable_for_nqt do
      suitable_for_nqt { "no" }
      job_roles { %w[] }
    end
  end
end
