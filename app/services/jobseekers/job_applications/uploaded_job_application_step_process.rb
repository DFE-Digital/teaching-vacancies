class Jobseekers::JobApplications::UploadedJobApplicationStepProcess
  ALL_STEPS = %w[
    personal_details
    upload_application_form
  ].freeze

  def steps
    ALL_STEPS
  end

  def validatable_steps
    steps
  end

  def form_class_for(step)
    "jobseekers/uploaded_job_application/#{step}_form".camelize.constantize
  end
end
