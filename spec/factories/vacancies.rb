JOB_TITLES = ["Tutor of Science",
              "PROGRESS LEADER (HEAD OF DEPARTMENT)",
              "Tutor of Music (Part time, permanent)",
              "Tutor of Maths MPS",
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
    benefits { true }
    benefits_details { Faker::Lorem.paragraph(sentence_count: factory_rand(1..3)) }
    completed_steps do
      %w[job_location job_role education_phases job_title key_stages subjects contract_type working_patterns pay_package important_dates start_date
         applying_for_the_job school_visits contact_details about_the_role include_additional_documents]
    end
    contact_email { Faker::Internet.email(domain: "example.com") }
    contact_number_provided { true }
    contact_number { "01234 123456" }
    contract_type { factory_sample(Vacancy.contract_types.keys) }
    fixed_term_contract_duration { "6 months" }
    further_details_provided { true }
    further_details { Faker::Lorem.paragraph(sentence_count: factory_rand(50..100)) }
    parental_leave_cover_contract_duration { "6 months" }
    expires_at { 6.months.from_now.change(hour: 9, minute: 0, second: 0) }
    hired_status { nil }
    include_additional_documents { false }
    job_advert { Faker::Lorem.paragraph(sentence_count: factory_rand(50..300)) }
    job_title { factory_sample(JOB_TITLES) }
    listed_elsewhere { nil }
    job_role { factory_sample(Vacancy.job_roles.keys) }
    ect_status { factory_sample(Vacancy.ect_statuses.keys) if job_role == "teacher" }
    pay_scale { factory_sample(SALARIES) }
    publish_on { Date.current }
    salary { factory_sample(SALARIES) }
    safeguarding_information_provided { true }
    safeguarding_information { Faker::Lorem.paragraph(sentence_count: factory_rand(50..100)) }
    school_offer { Faker::Lorem.paragraph(sentence_count: factory_rand(50..150)) }
    school_visits { true }
    skills_and_experience { Faker::Lorem.paragraph(sentence_count: factory_rand(50..150)) }
    start_date_type { "specific_date" }
    starts_on { 1.year.from_now.to_date }
    status { :published }
    subjects { factory_sample(SUBJECT_OPTIONS, 2).map(&:first).sort! }
    # TODO: Working Patterns: Remove call to #reject once all vacancies with legacy working patterns have expired
    working_patterns { factory_rand_sample(Vacancy.working_patterns.keys.reject { |working_pattern| working_pattern.in?(%w[flexible job_share term_time]) }, 1..2) }

    after(:build) do |v|
      v.full_time_details = Faker::Lorem.sentence(word_count: factory_rand(1..50)) if v.working_patterns.include?("full_time")
      v.part_time_details = Faker::Lorem.sentence(word_count: factory_rand(1..50)) if v.working_patterns.include?("part_time")
    end

    trait :no_tv_applications do
      receive_applications { "website" }
      application_link { Faker::Internet.url(host: "example.com") }
      enable_job_applications { false }
      how_to_apply { Faker::Lorem.paragraph(sentence_count: 4) }
      personal_statement_guidance { "" }
    end

    trait :central_office do
      phase { "multiple_phases" }
      organisations { build_list(:trust, 1) }
    end

    trait :at_one_school do
      organisations { build_list(:school, 1) }
    end

    trait :at_multiple_schools do
      organisations { build_list(:school, 3) }
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
      publish_on { Date.current + 6.months }
      expires_at { 18.months.from_now.change(hour: 9, minute: 0) }
      starts_on { 18.months.from_now + 2.months }
    end

    trait :past_publish do
      status { :published }
      sequence(:slug) { |n| "slug-#{n}" }
      publish_on { Date.current - 1.day }
      expires_at { 2.months.from_now.change(hour: 9, minute: 0) }
      starts_on { Date.current + 3.months }
    end

    trait :with_feedback do
      listed_elsewhere { :listed_paid }
      hired_status { :hired_tvs }
    end

    trait :with_supporting_documents do
      include_additional_documents { true }
      supporting_documents do
        [
          Rack::Test::UploadedFile.new(
            Rails.root.join("spec", "fixtures", "files", "blank_job_spec.pdf"),
            "application/pdf",
          ),
        ]
      end
    end

    trait :with_application_form do
      enable_job_applications { false }
      receive_applications { "email" }
      application_form do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec", "fixtures", "files", "blank_job_spec.pdf"),
          "application/pdf",
        )
      end
    end

    trait :external do
      external_source { "may_the_feed_be_with_you" }
      external_reference { "J3D1" }
      external_advert_url { "https://example.com/jobs/123" }
    end
  end
end
