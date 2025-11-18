FactoryBot.define do
  factory :job_application, class: "NativeJobApplication" do
    transient do
      draft_at { 2.weeks.ago }
      status { :draft }
      create_details { false }
      create_self_disclosure { false }
      create_references { false }
    end

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
    has_lived_abroad { true }
    life_abroad_details { Faker::Lorem.paragraph(sentence_count: 1) }

    # This field should really be called notify_before_contact_referees
    notify_before_contact_referers { false }

    completed_steps { JobApplication.completed_steps.keys }
    in_progress_steps { [] }

    after(:stub) do |job_application, options|
      if options.create_details
        build_stubbed_list(:referee, 1, job_application: job_application, is_most_recent_employer: true)
        build_stubbed_list(:qualification, 3, job_application: job_application)
        build_stubbed_list(:training_and_cpd, 2, job_application: job_application)
      end

      if options.create_self_disclosure
        self_disclosure_request = build_stubbed(:self_disclosure_request, :received, job_application:)
        build_stubbed(:self_disclosure, self_disclosure_request:)
      end

      if options.create_references
        referee_one = build_stubbed(:referee, job_application:)
        req_one = build_stubbed(:reference_request, :reference_received, referee: referee_one)
        build_stubbed(:job_reference, :reference_given, reference_request: req_one)
      end

      job_application.assign_attributes(
        # move status here to skip state machine validation
        status: options.status,
        draft_at: options.draft_at,
        submitted_at: options.submitted_at,
        unsuccessful_at: options.unsuccessful_at,
        reviewed_at: options.reviewed_at,
        shortlisted_at: options.shortlisted_at,
        interviewing_at: options.interviewing_at,
        unsuccessful_interview_at: options.unsuccessful_interview_at,
        offered_at: options.offered_at,
        declined_at: options.declined_at,
        withdrawn_at: options.withdrawn_at,
        rejected_at: options.rejected_at,
      )
    end

    after(:build) do |job_application, options|
      if options.create_details
        build_list(:referee, 1, job_application: job_application, is_most_recent_employer: true)
        build_list(:qualification, 3, job_application: job_application)
        build_list(:training_and_cpd, 2, job_application: job_application)
      end

      if options.create_self_disclosure
        self_disclosure_request = build(:self_disclosure_request, :received, job_application:)
        build(:self_disclosure, self_disclosure_request:)
      end

      if options.create_references
        referee_one = build(:referee, job_application:, is_most_recent_employer: true)
        req_one = build(:reference_request, :reference_received, referee: referee_one)
        build(:job_reference, :reference_given, reference_request: req_one)
        job_application.referees << referee_one
      end
    end

    after(:create) do |job_application, options|
      if options.create_details
        create_list(:referee, 1, job_application: job_application, is_most_recent_employer: true)
        create_list(:qualification, 3, job_application: job_application)
        create_list(:training_and_cpd, 2, job_application: job_application)
      end

      job_application.update_columns(
        # move status here to skip state machine validation
        status: options.status,
        draft_at: options.draft_at,
        submitted_at: options.submitted_at,
        unsuccessful_at: options.unsuccessful_at,
        reviewed_at: options.reviewed_at,
        shortlisted_at: options.shortlisted_at,
        interviewing_at: options.interviewing_at,
        unsuccessful_interview_at: options.unsuccessful_interview_at,
        offered_at: options.offered_at,
        declined_at: options.declined_at,
        withdrawn_at: options.withdrawn_at,
        rejected_at: options.rejected_at,
      )
    end
  end

  trait :for_seed_data do
    create_details { true }
    disability { %w[no prefer_not_to_say yes].sample }
    age { %w[under_twenty_five twenty_five_to_twenty_nine thirty_to_thirty_nine forty_to_forty_nine fifty_to_fifty_nine sixty_and_over prefer_not_to_say].sample }
    gender { %w[man other prefer_not_to_say woman].sample }
    gender_description { Faker::Gender.type }
    orientation { %w[bisexual gay_or_lesbian heterosexual other prefer_not_to_say].sample }
    orientation_description { Faker::Lorem.sentence }
    ethnicity { %w[asian black mixed other prefer_not_to_say white].sample }
    ethnicity_description { Faker::Lorem.sentence }
    religion { %w[buddhist christian hindu jewish muslim none other prefer_not_to_say sikh].sample }
    religion_description { Faker::Religion::Bible.character }
    national_insurance_number { ["QQ 12 34 56 C", nil].sample }
  end

  trait :status_draft do
    transient do
      create_details { false }
      status { :draft }
    end

    # Personal details
    first_name { "" }
    last_name { "" }
    previous_names { "" }
    street_address { "" }
    city { "" }
    postcode { "" }
    country { "" }
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
    has_lived_abroad { nil }
    life_abroad_details { "" }

    completed_steps { [] }
  end

  trait :status_submitted do
    transient do
      submitted_at { 4.days.ago }
      status { :submitted }
    end
  end

  trait :status_reviewed do
    transient do
      submitted_at { 4.days.ago }
      reviewed_at { 3.days.ago }
      status { :reviewed }
    end
  end

  trait :status_shortlisted do
    transient do
      submitted_at { 4.days.ago }
      shortlisted_at { 3.days.ago }
      status { :shortlisted }
    end

    further_instructions { Faker::Lorem.paragraph(sentence_count: 2) }
  end

  trait :status_unsuccessful do
    transient do
      submitted_at { 4.days.ago }
      unsuccessful_at { 3.days.ago }
      status { :unsuccessful }
    end

    rejection_reasons { Faker::Lorem.paragraph(sentence_count: 1) }
  end

  trait :status_rejected do
    transient do
      submitted_at { 4.days.ago }
      unsuccessful_at { 3.days.ago }
      rejected_at { 2.days.ago }
      status { :rejected }
    end

    rejection_reasons { Faker::Lorem.paragraph(sentence_count: 1) }
  end

  trait :status_withdrawn do
    transient do
      submitted_at { 4.days.ago }
      withdrawn_at { 2.days.ago }
      status { :withdrawn }
    end
  end

  trait :status_interviewing do
    transient do
      submitted_at { 4.days.ago }
      shortlisted_at { 3.days.ago }
      interviewing_at { 2.days.ago }
      status { :interviewing }
    end
  end

  trait :status_interviewing_with_pre_checks do
    transient do
      submitted_at { 4.days.ago }
      interviewing_at { 2.days.ago }
      status { :interviewing }
      create_self_disclosure { true }
      create_references { true }
    end
  end

  trait :status_unsuccessful_interview do
    transient do
      status { :unsuccessful_interview }
      submitted_at { 4.days.ago }
      interviewing_at { 2.days.ago }
      unsuccessful_interview_at { 1.day.ago }
      create_self_disclosure { true }
      create_references { true }
    end

    interview_feedback_received_at { Time.zone.now }
    interview_feedback_received { true }
  end

  trait :status_offered do
    transient do
      status { :offered }
      submitted_at { 4.days.ago }
      shortlisted_at { 3.days.ago }
      interviewing_at { 2.days.ago }
      offered_at { 1.day.ago }
      create_self_disclosure { true }
      create_references { true }
    end
  end

  trait :status_declined do
    transient do
      status { :declined }
      submitted_at { 5.days.ago }
      shortlisted_at { 4.days.ago }
      interviewing_at { 2.days.ago }
      offered_at { 1.day.ago }
      declined_at { Time.zone.now }
      create_self_disclosure { true }
      create_references { true }
    end
  end

  trait :with_baptism_certificate do
    following_religion { true }
    religious_reference_type { :baptism_certificate }
    baptism_certificate do
      Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"),
        "application/pdf",
      )
    end
  end

  trait :with_religious_referee do
    religious_reference_type { :religious_referee }
    religious_referee_name { Faker::Name.name }
    religious_referee_address { Faker::Address.full_address }
    religious_referee_role { "Priest" }
    religious_referee_email { Faker::Internet.email(domain: "contoso.com") }
    religious_referee_phone { Faker::PhoneNumber.phone_number }
  end
end
