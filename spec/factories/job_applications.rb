FactoryBot.define do
  factory :job_application do
    transient do
      draft_at { 2.weeks.ago }
      shortlisted_at { 2.days.ago }
      submitted_at { 3.days.ago }
      unsuccessful_at { 1.day.ago }
      withdrawn_at { 1.week.ago }
      create_details { true }
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
    phone_number { "01234 567890" }
    teacher_reference_number { "12345678" }
    national_insurance_number { "QQ 12 34 56 C" }

    # Professional statement
    qualified_teacher_status { "yes" }
    qualified_teacher_status_year { "1990" }
    statutory_induction_complete { "yes" }

    # Employment history
    gaps_in_employment { "yes" }
    gaps_in_employment_details { Faker::Lorem.paragraph(sentence_count: 2) }

    # Personal statement
    personal_statement { Faker::Lorem.paragraph(sentence_count: 8) }

    # Ask for support
    support_needed { "yes" }
    support_needed_details { Faker::Lorem.paragraph(sentence_count: 2) }

    # Equal opportunities
    disability { "no" }
    gender { "other" }
    gender_description { Faker::Lorem.sentence }
    orientation { "other" }
    orientation_description { Faker::Lorem.sentence }
    ethnicity { "other" }
    ethnicity_description { Faker::Lorem.sentence }
    religion { "other" }
    religion_description { Faker::Lorem.sentence }

    # Declarations
    close_relationships { "yes" }
    close_relationships_details { Faker::Lorem.paragraph(sentence_count: 1) }
    right_to_work_in_uk { "yes" }

    completed_steps { JobApplication.completed_steps.keys }
    in_progress_steps { [] }

    after :create do |job_application, options|
      if options.create_details
        create_list :employment, 3, job_application: job_application
        create_list :reference, 2, job_application: job_application
        create_list :qualification, 3, job_application: job_application
      end

      job_application.update_columns(
        draft_at: options.draft_at,
        shortlisted_at: options.shortlisted_at,
        submitted_at: options.submitted_at,
        unsuccessful_at: options.unsuccessful_at,
        withdrawn_at: options.withdrawn_at,
      )
    end
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
    phone_number { "" }
    teacher_reference_number { "" }
    national_insurance_number { "" }

    # Professional statement
    qualified_teacher_status { "" }
    qualified_teacher_status_year { "" }
    statutory_induction_complete { "" }

    # Employment history
    gaps_in_employment { "" }
    gaps_in_employment_details { "" }

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
    support_needed { "" }
    support_needed_details { "" }

    # Declarations
    close_relationships { "" }
    close_relationships_details { "" }
    right_to_work_in_uk { "" }

    completed_steps { [] }
  end

  trait :status_shortlisted do
    status { :shortlisted }
    further_instructions { Faker::Lorem.paragraph(sentence_count: 2) }
  end

  trait :status_submitted do
    status { :submitted }
  end

  trait :status_unsuccessful do
    status { :unsuccessful }
    rejection_reasons { Faker::Lorem.paragraph(sentence_count: 1) }
  end

  trait :status_withdrawn do
    status { :withdrawn }
  end
end
