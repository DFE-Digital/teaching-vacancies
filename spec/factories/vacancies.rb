JOB_TITLES = ["Tutor of Science (opportunity exists for the right candidate for Head of Physics and/or KS4 Lead)",
              "PROGRESS LEADER (HEAD OF DEPARTMENT) FOR RS, PSHE, RSE AND CITIZENSHIP EDUCATION WITH TLR 2 £6698",
              "Tutor of Music (Part time, permanent) to include Music Performance Enhancement project for 1 year",
              "Tutor of Maths MPS (A recruitment and retention point will be offered to the successful candidate)",
              "Tutor of PE (male)", "Games Design Tutor", "Team Leader of Maths", "KEY STAGE 2 Tutor",
              "Lead in Health and Social Care", "Director of Learning - Science"].freeze

SALARIES = ["Main pay range 1 to Upper pay range 3, £23,719 to £39,406 per year (full time equivalent)",
            "£6,084 to £6,084 per year (full time equivalent)", "Main pay range 2 to Upper pay range 3, £30,113 to £44,541",
            "Main pay range 1 to Upper pay range 3, £30,480 to £49,571", "MPR / UPR",
            "MPS/UPS", "£25,543 to £41,635 per year (full time equivalent)"].freeze

FactoryBot.define do
  factory :vacancy do
    publisher

    about_school { Faker::Lorem.paragraph(sentence_count: factory_rand(5..10)) }
    actual_salary { factory_rand(20_000..100_000) }
    enable_job_applications { true }
    benefits { Faker::Lorem.paragraph(sentence_count: factory_rand(1..3)) }
    completed_steps do
      %w[job_role job_role_details job_location schools job_details working_patterns pay_package important_dates documents applying_for_the_job job_summary]
    end
    contact_email { Faker::Internet.email(domain: "example.com") }
    contact_number { "01234 123456" }
    contract_type { factory_sample(Vacancy.contract_types.keys) }
    contract_type_duration { "6 months" }
    expires_at { 6.months.from_now.change(hour: 9, minute: 0, second: 0) }
    hired_status { nil }
    job_advert { Faker::Lorem.paragraph(sentence_count: factory_rand(50..300)) }
    job_location { "at_one_school" }
    job_title { factory_sample(JOB_TITLES) }
    listed_elsewhere { nil }
    main_job_role { factory_sample(Vacancy.main_job_role_options) }
    additional_job_roles do
      case main_job_role
      when "teacher"
        factory_rand_sample(Vacancy.additional_job_role_options, 0..2)
      when "sendco"
        []
      else
        factory_rand_sample(["send_responsible"], 0..1)
      end
    end
    personal_statement_guidance { Faker::Lorem.paragraph(sentence_count: factory_rand(5..10)) }
    publish_on { Date.current }
    salary { factory_sample(SALARIES) }
    school_visits { Faker::Lorem.paragraph(sentence_count: factory_rand(5..10)) }
    starts_on { 1.year.from_now.to_date }
    status { :published }
    subjects { factory_sample(SUBJECT_OPTIONS, 2).map(&:first).sort! }
    working_patterns { factory_rand_sample(Vacancy.working_patterns.keys, 1..3) }
    working_patterns_details { Faker::Lorem.paragraph(sentence_count: 1) }

    trait :no_tv_applications do
      application_link { Faker::Internet.url(host: "example.com") }
      enable_job_applications { false }
      how_to_apply { Faker::Lorem.paragraph(sentence_count: 4) }
      personal_statement_guidance { "" }
    end

    trait :central_office do
      phase { "multiple_phases" }
      job_location { "central_office" }
      readable_job_location { I18n.t("publishers.organisations.readable_job_location.central_office") }
    end

    trait :at_one_school do
      job_location { "at_one_school" }
      readable_job_location { Faker::Educator.secondary_school.strip.delete("'") }
      postcode_from_mean_geolocation { "A99 B99" }
    end

    trait :at_multiple_schools do
      job_location { "at_multiple_schools" }
      readable_job_location { "More than one school (2)" }
      postcode_from_mean_geolocation { "Z89 Y76" }
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
      deterministic_sequence(:slug) { |n| "slug-#{n}" }
    end

    trait :expired do
      to_create { |instance| instance.save(validate: false) }
      status { :published }
      deterministic_sequence(:slug) { |n| "slug-#{n}" }
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
      publish_on { Date.current + 6.months }
      expires_at { 18.months.from_now.change(hour: 9, minute: 0) }
      starts_on { 18.months.from_now + 2.months }
    end

    trait :past_publish do
      status { :published }
      deterministic_sequence(:slug) { |n| "slug-#{n}" }
      publish_on { Date.current - 1.day }
      expires_at { 2.months.from_now.change(hour: 9, minute: 0) }
      starts_on { Date.current + 3.months }
    end

    trait :without_working_patterns do
      to_create { |instance| instance.save(validate: false) }
      deterministic_sequence(:slug) { |n| "slug-#{n}" }
      working_patterns { nil }
    end

    trait :with_feedback do
      listed_elsewhere { :listed_paid }
      hired_status { :hired_tvs }
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
