FactoryBot.define do
  factory :native_job_application do
    transient do
      draft_at { 2.weeks.ago }
      create_details { false }
    end

    status { :draft }
    jobseeker
    vacancy

    # Personal details
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    previous_names { Faker::Name.name }
    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    postcode { Faker::Address.postcode }
    country { Faker::Address.country }
    email_address { Faker::Internet.email(domain: "contoso.com") }
    phone_number { "01234 567890" }
    teacher_reference_number { "1234567" }
    national_insurance_number { "QQ 12 34 56 C" }
    working_patterns { %w[part_time] }
    working_pattern_details { "I don't do mornings" }

    # Professional statement
    qualified_teacher_status { "yes" }
    qualified_teacher_status_year { "1990" }
    is_statutory_induction_complete { true }

    # Personal statement
    personal_statement { Faker::Lorem.paragraph(sentence_count: 8) }

    # Ask for support
    is_support_needed { true }
    support_needed_details { Faker::Lorem.paragraph(sentence_count: 2) }

    # Equal opportunities
    disability { "no" }
    age { "under_twenty_five" }
    gender { "other" }
    gender_description { Faker::Lorem.sentence }
    orientation { "other" }
    orientation_description { Faker::Lorem.sentence }
    ethnicity { "other" }
    ethnicity_description { Faker::Lorem.sentence }
    religion { "other" }
    religion_description { Faker::Lorem.sentence }

    # Declarations
    has_close_relationships { true }
    close_relationships_details { Faker::Lorem.paragraph(sentence_count: 1) }
    has_safeguarding_issue { true }
    safeguarding_issue_details { Faker::Lorem.paragraph(sentence_count: 1) }
    has_right_to_work_in_uk { true }

    completed_steps { JobApplication.completed_steps.keys }
    in_progress_steps { [] }

    after :create do |job_application, options|
      if options.create_details
        create_list(:referee, 1, job_application: job_application, is_most_recent_employer: true)
        create_list(:qualification, 3, job_application: job_application)
        create_list(:training_and_cpd, 2, job_application: job_application)
      end

      job_application.update_columns(
        draft_at: options.draft_at,
        reviewed_at: options.reviewed_at,
        shortlisted_at: options.shortlisted_at,
        submitted_at: options.submitted_at,
        unsuccessful_at: options.unsuccessful_at,
        withdrawn_at: options.withdrawn_at,
      )
    end
  end

  trait :for_seed_data do
    create_details { true }
  end

  trait :status_draft do
    transient do
      create_details { false }
    end

    status { :draft }

    # Personal details
    first_name { "" }
    last_name { "" }
    previous_names { "" }
    street_address { "" }
    city { "" }
    postcode { "" }
    country { "" }
    email_address { "" }
    phone_number { "" }
    teacher_reference_number { "" }
    national_insurance_number { "" }

    # Professional statement
    qualified_teacher_status { "" }
    qualified_teacher_status_year { "" }
    is_statutory_induction_complete { nil }

    # Personal statement
    personal_statement { "" }

    # Equal opportunities
    disability { "" }
    gender { "" }
    gender_description { "" }
    orientation { "" }
    orientation_description { "" }
    ethnicity { "" }
    ethnicity_description { "" }
    religion { "" }
    religion_description { "" }

    # Ask for support
    is_support_needed { nil }
    support_needed_details { "" }

    # Declarations
    has_close_relationships { nil }
    close_relationships_details { "" }
    has_safeguarding_issue { nil }
    safeguarding_issue_details { "" }
    has_right_to_work_in_uk { nil }

    completed_steps { [] }
  end

  trait :status_reviewed do
    transient do
      submitted_at { 4.days.ago }
      reviewed_at { 3.days.ago }
    end

    status { :reviewed }
  end

  trait :status_shortlisted do
    transient do
      submitted_at { 4.days.ago }
      reviewed_at { 3.days.ago }
      shortlisted_at { 2.days.ago }
    end

    status { :shortlisted }
    further_instructions { Faker::Lorem.paragraph(sentence_count: 2) }
  end

  trait :status_submitted do
    transient do
      submitted_at { 4.days.ago }
    end

    status { :submitted }
  end

  trait :status_unsuccessful do
    transient do
      submitted_at { 4.days.ago }
      reviewed_at { 3.days.ago }
      unsuccessful_at { 2.days.ago }
    end

    status { :unsuccessful }
    rejection_reasons { Faker::Lorem.paragraph(sentence_count: 1) }
  end

  trait :status_withdrawn do
    transient do
      submitted_at { 4.days.ago }
      withdrawn_at { 2.days.ago }
    end

    status { :withdrawn }
  end

  trait :status_interviewing do
    transient do
      submitted_at { 4.days.ago }
      interviewing_at { 2.days.ago }
    end

    status { :interviewing }
  end
end
