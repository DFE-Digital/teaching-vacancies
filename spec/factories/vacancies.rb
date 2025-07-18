FactoryBot.define do
  job_titles = [
    "Tutor of Science",
    "PROGRESS LEADER (HEAD OF DEPARTMENT)",
    "Tutor of Music (Part time, permanent)",
    "Tutor of Maths MPS",
    "Tutor of PE (male)",
    "Games Design Tutor",
    "Team Leader of Maths",
    "KEY STAGE 2 Tutor",
    "Lead in Health and Social Care",
    "Director of Learning - Science",
  ].freeze

  sequence :job_title do |n|
    "#{job_titles.sample} #{n}"
  end

  factory :vacancy, class: "PublishedVacancy" do
    salaries = [
      "Main pay range 1 to Upper pay range 3, £23,719 to £39,406 per year (full time equivalent)",
      "£6,084 to £6,084 per year (full time equivalent)",
      "Main pay range 2 to Upper pay range 3, £30,113 to £44,541",
      "Main pay range 1 to Upper pay range 3, £30,480 to £49,571",
      "MPR / UPR",
      "MPS/UPS",
      "£25,543 to £41,635 per year (full time equivalent)",
    ].freeze

    publisher

    actual_salary { factory_rand(20_000..100_000) }
    enable_job_applications { true }
    benefits { true }
    benefits_details { Faker::Lorem.paragraph(sentence_count: factory_rand(1..3)) }
    completed_steps do
      %w[job_location job_role education_phases job_title key_stages subjects contract_type working_patterns pay_package important_dates start_date
         applying_for_the_job school_visits contact_details about_the_role include_additional_documents]
    end
    contact_email { Faker::Internet.email(domain: "contoso.com") }
    contact_number_provided { true }
    contact_number { "01234 123456" }
    contract_type { factory_sample(Vacancy.contract_types.keys) }
    fixed_term_contract_duration { "6 months" }
    further_details_provided { true }
    further_details { Faker::Lorem.sentence(word_count: factory_rand(50..300)) }
    expires_at { 6.months.from_now.change(hour: 9, minute: 0, second: 0) }
    hired_status { nil }
    include_additional_documents { false }
    job_title { Rails.env.production? ? factory_sample(job_titles) : generate(:job_title) }
    listed_elsewhere { nil }
    job_roles { %w[teacher] }
    ect_status { factory_sample(Vacancy.ect_statuses.keys) if job_roles.include?("teacher") }
    pay_scale { factory_sample(salaries) }
    publish_on { Date.current }
    salary { factory_sample(salaries) }
    hourly_rate { "£25 per hour" }
    school_offer { Faker::Lorem.sentence(word_count: factory_rand(50..150)) }
    school_visits { true }
    skills_and_experience { Faker::Lorem.sentence(word_count: factory_rand(50..150)) }
    start_date_type { "specific_date" }
    starts_on { 1.year.from_now.to_date }
    # Subjects are ignored when phases are primary-only
    subjects { factory_sample(SUBJECT_OPTIONS, 2).map(&:first).sort! }
    key_stages { %w[ks1] }
    working_patterns_details { Faker::Lorem.sentence(word_count: factory_rand(1..50)) }
    working_patterns { %w[full_time] }
    visa_sponsorship_available { false }
    organisations { build_list(:school, 1) }
    is_job_share { false }
    flexi_working_details_provided { true }
    flexi_working { Faker::Lorem.sentence(word_count: factory_rand(50..150)) }

    trait :for_seed_data do
      job_roles { [factory_sample(Vacancy.job_roles.keys)] }
      is_job_share { [true, false].sample }
      working_patterns { factory_rand_sample(%w[full_time part_time], 1..2) }
      working_patterns_details { Faker::Lorem.sentence(word_count: factory_rand(1..50)) }
      phases { factory_rand_sample(Vacancy.phases.keys, 1..3) }
      key_stages { factory_rand_sample(%w[early_years ks1 ks2 ks3 ks4 ks5], 2..3) }
    end

    trait :without_any_money do
      salary { nil }
      hourly_rate { nil }
      pay_scale { nil }
      actual_salary { nil }
    end

    trait :no_tv_applications do
      receive_applications { "website" }
      application_link { Faker::Internet.url(host: "contoso.com") }
      enable_job_applications { false }
    end

    trait :central_office do
      organisations { build_list(:trust, 1) }
    end

    trait :at_one_school do
      organisations { build_list(:school, 1) }
    end

    trait :at_multiple_schools do
      organisations { build_list(:school, 3) }
    end

    trait :trashed do
      discarded_at { Time.zone.now }
    end

    trait :live do
      publish_on { 1.week.ago }
    end

    trait :published_slugged do
      sequence(:slug) { |n| "slug-#{n}" }
    end

    trait :expired do
      to_create { |instance| instance.save(validate: false) }
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
      publish_on { Date.current + 6.months }
      expires_at { 18.months.from_now.change(hour: 9, minute: 0) }
      starts_on { 18.months.from_now + 2.months }
    end

    trait :past_publish do
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
            Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"),
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
          Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"),
          "application/pdf",
        )
      end
    end

    trait :catholic do
      religion_type { :catholic }
    end

    trait :other_religion do
      religion_type { :other_religion }
    end

    trait :with_uploaded_application_form do
      enable_job_applications { false }
      receive_applications { "uploaded_form" }
      application_form do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"),
          "application/pdf",
        )
      end
    end

    trait :external do
      enable_job_applications { false }
      about_school { Faker::Lorem.paragraph(sentence_count: factory_rand(5..10)) }
      job_advert { Faker::Lorem.paragraph(sentence_count: factory_rand(50..300)) }
      publisher_ats_api_client
      external_source { "may_the_feed_be_with_you" }
      external_reference { "J3D1" }
      external_advert_url { "https://example.com/jobs/123" }
      phases { %w[secondary] }
      skills_and_experience { nil }
      actual_salary { nil }
      school_offer { nil }
      flexi_working { nil }
    end

    factory :draft_vacancy, class: "DraftVacancy" do
      completed_steps do
        %w[job_location job_role education_phases job_title key_stages subjects contract_type working_patterns pay_package start_date
           applying_for_the_job school_visits contact_details about_the_role include_additional_documents]
      end

      trait :with_contract_details do
        completed_steps do
          %w[job_location job_role job_title education_phases key_stages subjects contract_information pay_package start_date]
        end
      end

      trait :without_contract_details do
        completed_steps do
          %w[job_location job_role]
        end
      end
    end
  end
end
