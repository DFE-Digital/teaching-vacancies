class UploadedJobApplication < JobApplication
  has_one_attached :application_form

  def uploaded_file
    application_form.blob if application_form.attached?
  end
end
