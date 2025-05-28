class Jobseekers::JobApplications::JobApplicationHandler
  def initialize(job_application, step_process)
    @job_application = job_application
    @step_process = step_process
  end

  def all_steps_valid?
    all_steps.all? { |step| valid_step?(step) }
  end

  def all_steps
    if uploaded_job_application?
      UploadedJobApplication::ALL_STEPS
    else
      @step_process.steps.excluding(:review).map(&:to_s)
    end
  end

  private

  def valid_step?(step)
    form_class = form_class_for(step)
    form = form_class.new(form_class.load_form(@job_application))
    is_valid = form.valid?
    @job_application.errors.merge!(form.errors)

    is_valid
  end

  def uploaded_job_application?
    @job_application.is_a?(UploadedJobApplication)
  end

  def form_class_for(step)
    prefix = uploaded_job_application? ? "jobseekers/uploaded_job_application" : "jobseekers/job_application"
    "#{prefix}/#{step}_form".camelize.constantize
  end
end
