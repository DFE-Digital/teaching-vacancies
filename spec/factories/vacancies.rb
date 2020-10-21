FactoryBot.define do
  factory :vacancy do
    association :leadership

    after :create do |vacancy|
      create_list :document, 3, vacancy: vacancy
    end

    job_location { 'at_one_school' }
    about_school { Faker::Lorem.paragraph(sentence_count: 4) }
    application_link { Faker::Internet.url }
    benefits { Faker::Lorem.paragraph(sentence_count: 4) }
    contact_email { Faker::Internet.email }
    contact_number { '01234 123456' }
    education { Faker::Lorem.paragraph(sentence_count: 4) }
    experience { Faker::Lorem.paragraph(sentence_count: 4) }
    expires_on { Faker::Time.forward(days: 14) }
    expiry_time { expires_on&.change(sec: 0) }
    hired_status { nil }
    how_to_apply { Faker::Lorem.paragraph(sentence_count: 4) }
    job_summary { Faker::Lorem.paragraph(sentence_count: 4) }
    job_roles { [:teacher] }
    job_title { Faker::Lorem.sentence[1...30].strip }
    listed_elsewhere { nil }
    publish_on { Time.zone.today }
    qualifications { Faker::Lorem.paragraph(sentence_count: 4) }
    reference { SecureRandom.uuid }
    salary { Faker::Lorem.sentence[1...30].strip }
    school_visits { Faker::Lorem.paragraph(sentence_count: 4) }
    state { 'create' }
    starts_on { Time.zone.today + 1.year }
    status { :published }
    subjects { SUBJECT_OPTIONS.sample(2).map(&:first).sort! }
    supporting_documents { 'yes' }
    suitable_for_nqt { 'no' }
    working_patterns { %w[full_time] }

    trait :at_central_office do
      job_location { 'central_office' }
      readable_job_location { I18n.t('hiring_staff.organisations.readable_job_location.central_office') }
    end

    trait :at_one_school do
      job_location { 'at_one_school' }
      readable_job_location { Faker::Educator.secondary_school.strip.gsub("'", '') }
    end

    trait :at_multiple_schools do
      job_location { 'at_multiple_schools' }
      readable_job_location { 'More than one school (3)' }
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
      starts_on { Faker::Time.between(from: Time.zone.today + 10.days, to: Time.zone.today + 30.days) }
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

    trait :with_no_expiry_time do
      status { :published }
      expires_on { Faker::Time.between(from: Time.zone.today + 10.days, to: Time.zone.today + 20.days) }
      expiry_time { nil }
    end

    trait :suitable_for_nqt do
      suitable_for_nqt { 'yes' }
      job_roles { %w[nqt_suitable] }
    end

    trait :not_suitable_for_nqt do
      suitable_for_nqt { 'no' }
      job_roles { %w[] }
    end
  end
end
