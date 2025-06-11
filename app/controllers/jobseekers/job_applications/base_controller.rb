class Jobseekers::JobApplications::BaseController < Jobseekers::BaseController
  helper_method :job_application

  def step_process
    if job_application.vacancy.uploaded_form?
      Jobseekers::JobApplications::UploadedJobApplicationStepProcess.new
    else
      Jobseekers::JobApplications::JobApplicationStepProcess.new(job_application: self)
    end
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
