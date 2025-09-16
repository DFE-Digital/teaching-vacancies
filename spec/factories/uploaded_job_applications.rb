FactoryBot.define do
  factory :uploaded_job_application, parent: :job_application, class: "UploadedJobApplication" do
    jobseeker
    vacancy factory: %i[vacancy with_uploaded_application_form]

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email_address { Faker::Internet.email(domain: "contoso.com") }
    phone_number { "01234 567890" }
    teacher_reference_number { "1234567" }
    has_right_to_work_in_uk { true }

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
        build_stubbed(:reference_request, :reference_received, referee: referee_one)
        build_stubbed(:job_reference, :reference_given, referee: referee_one)
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
      )
    end

    trait :with_uploaded_application_form do
      after(:build) do |uploaded_job_application|
        uploaded_job_application.application_form.attach(
          io: Rails.root.join("spec/fixtures/files/blank_baptism_cert.pdf").open,
          filename: "application_form.pdf",
          content_type: "application/pdf",
        )
      end
    end
  end
end
