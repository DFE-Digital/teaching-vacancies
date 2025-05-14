class UploadedJobApplication < JobApplication
  has_one_attached :application_form

  ALL_STEPS = [
    "personal_details",
    "upload_application_form"
  ]
end
