class Jobseekers::JobApplications::BaseController < Jobseekers::BaseController
  include Jobseekers::Wizardable

  helper_method :job_application

  def step_process
    if vacancy.religion_type.present?
      Jobseekers::JobApplications::ReligiousJobApplicationStepProcess.new(
        job_application: job_application,
      )
    else
      Jobseekers::JobApplications::JobApplicationStepProcess.new(

        job_application: job_application,
      )
    end
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
