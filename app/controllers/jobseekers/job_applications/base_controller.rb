class Jobseekers::JobApplications::BaseController < Jobseekers::BaseController
  include Jobseekers::Wizardable

  helper_method :job_application

  def step_process
    Jobseekers::JobApplications::JobApplicationStepProcess.new(
      job_application: job_application,
    )
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
