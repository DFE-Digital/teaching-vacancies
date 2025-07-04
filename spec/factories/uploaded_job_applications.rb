FactoryBot.define do
  factory :uploaded_job_application do
    status { :draft }
    jobseeker
    vacancy factory: %i[vacancy with_uploaded_application_form]

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email_address { Faker::Internet.email(domain: "contoso.com") }
    phone_number { "01234 567890" }
    teacher_reference_number { "1234567" }
    has_right_to_work_in_uk { true }

    trait :with_uploaded_application_form do
      after(:build) do |uploaded_job_application|
        uploaded_job_application.application_form.attach(
          io: Rails.root.join("spec/fixtures/files/blank_baptism_cert.pdf").open,
          filename: "application_form.pdf",
          content_type: "application/pdf",
        )
      end
    end

    trait :status_submitted do
      transient do
        submitted_at { 4.days.ago }
      end

      status { :submitted }
    end
  end
end
