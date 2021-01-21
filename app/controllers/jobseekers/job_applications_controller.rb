class Jobseekers::JobApplicationsController < Jobseekers::ApplicationController
  before_action :set_up_vacancy, only: %i[new create]
  before_action :set_up_job_application, only: %i[review submit]

  def create
    job_application = current_jobseeker.job_applications.create(status: :draft, vacancy: @vacancy)
    redirect_to jobseekers_job_application_build_path(job_application, :personal_details)
  end

  def submit
    @job_application.update(status: :submitted)
  end

  private

  def set_up_vacancy
    @vacancy = Vacancy.live.find(params[:job_id])
  end

  def set_up_job_application
    @job_application = current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
