FactoryBot.define do
  factory :vacancy do
    publisher

    job_location { "at_one_school" }
    about_school { "Great school with amazing people" }
    enable_job_applications { true }
    benefits { Faker::Lorem.paragraph(sentence_count: 4) }
    completed_step { 7 }
    completed_steps { %w[job_location schools job_details pay_package important_dates documents applying_for_the_job job_summary] }
    contact_email { Faker::Internet.email }
    contact_number { "01234 123456" }
    contract_type { :fixed_term }
    contract_type_duration { "6 months" }
    expires_at { 6.months.from_now.change(hour: 9, minute: 0, second: 0) }
    hired_status { nil }
    job_advert { Faker::Lorem.paragraph(sentence_count: 4) }
    job_roles { [:teacher] }
    job_title { Faker::Lorem.sentence[1...30].strip }
    listed_elsewhere { nil }
    personal_statement_guidance { Faker::Lorem.paragraph(sentence_count: 4) }
    publish_on { Date.current }
    salary { Faker::Lorem.sentence[1...30].strip }
    school_visits { Faker::Lorem.paragraph(sentence_count: 4) }
    starts_on { 1.year.from_now.to_date }
    status { :published }
    subjects { SUBJECT_OPTIONS.sample(2).map(&:first).sort! }
    suitable_for_nqt { "no" }
    working_patterns { %w[full_time] }

    trait :no_tv_applications do
      application_link { Faker::Internet.url(host: "example.com") }
      enable_job_applications { false }
      how_to_apply { Faker::Lorem.paragraph(sentence_count: 4) }
      personal_statement_guidance { "" }
    end

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
      job_advert { Faker::Lorem.paragraph[0..5] }
      job_title { Faker::Job.title[0..2] }
    end

    trait :fail_maximum_validation do
      job_advert { Faker::Lorem.characters(number: 50_001) }
      job_title { Faker::Lorem.characters(number: 150) }
      salary { Faker::Lorem.characters(number: 257) }
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
    end

    trait :published_slugged do
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
    end

    trait :expired do
      to_create { |instance| instance.save(validate: false) }
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
      publish_on { Date.current - 1.month }
      expires_at { 2.weeks.ago.change(hour: 9, minute: 0) }
    end

    trait :expired_yesterday do
      expires_at { 1.day.ago.change(hour: 9, minute: 0) }
    end

    trait :expired_years_ago do
      expires_at { 2.years.ago.change(hour: 9, minute: 0) }
    end

    trait :expires_tomorrow do
      expires_at { 1.day.from_now.change(hour: 9, minute: 0) }
    end

    trait :future_publish do
      status { :published }
      publish_on { Date.current + 2.days }
      expires_at { 2.months.from_now.change(hour: 9, minute: 0) }
    end

    trait :past_publish do
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
      publish_on { Date.current - 1.day }
      expires_at { 2.months.from_now.change(hour: 9, minute: 0) }
      starts_on { Date.current + 3.months }
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

    trait :with_supporting_documents do
      supporting_documents do
        [
          Rack::Test::UploadedFile.new(
            Rails.root.join("spec", "fixtures", "files", "blank_job_spec.pdf"),
            "application/pdf",
          ),
        ]
      end
    end
  end
end
