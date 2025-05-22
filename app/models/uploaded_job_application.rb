class UploadedJobApplication < JobApplication
  has_one_attached :application_form

  ALL_STEPS = %w[
    personal_details
    upload_application_form
  ].freeze
end
