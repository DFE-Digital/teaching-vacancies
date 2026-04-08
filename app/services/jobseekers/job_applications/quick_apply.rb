class Jobseekers::JobApplications::QuickApply
  def initialize(jobseeker, vacancy)
    @jobseeker = jobseeker
    @vacancy = vacancy
  end

  def job_application
    return new_job_application if @vacancy.uploaded_form?
    return new_job_application unless current_jobseeker.has_submitted_native_job_application?

    Jobseekers::JobApplications::PrefillJobApplicationFromPreviousApplication.new(jobseeker, new_job_application).call
  end

  private

  attr_reader :jobseeker, :vacancy

  def new_job_application
    vacancy.create_job_application_for(jobseeker)
  end
end
