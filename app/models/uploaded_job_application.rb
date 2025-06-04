class UploadedJobApplication < JobApplication
  has_one_attached :application_form

  array_enum completed_steps: {
    personal_details: 0,
    upload_application_form: 13,
  }

  ALL_STEPS = %w[
    personal_details
    upload_application_form
  ].freeze
end
