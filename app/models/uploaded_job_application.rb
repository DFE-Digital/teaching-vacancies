class UploadedJobApplication < JobApplication
  has_one_attached :application_form

  def form_class_for(step)
    "jobseekers/uploaded_job_application/#{step}_form".camelize.constantize
  end
end
