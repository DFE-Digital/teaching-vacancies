class Jobseekers::JobApplications::BaseController < Jobseekers::BaseController
  helper_method :job_application

  def step_process
    job_application.step_process
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
