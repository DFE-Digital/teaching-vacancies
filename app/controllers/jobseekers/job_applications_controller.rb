class Jobseekers::JobApplicationsController < Jobseekers::ApplicationController
  helper_method :job_application, :vacancy

  def new
    request_event.trigger(:vacancy_apply_clicked, vacancy_id: vacancy.id)
  end

  def create
    new_job_application = current_jobseeker.job_applications.find_or_initialize_by(vacancy: vacancy)
    new_job_application.draft!
    redirect_to jobseekers_job_application_build_path(new_job_application, :personal_details)
  end

  def submit
    job_application.update(status: :submitted)
  end

  private

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end

  def vacancy
    @vacancy ||= if params[:job_id].present?
                   Vacancy.live.find(params[:job_id])
                 else
                   job_application.vacancy
                 end
  end
end
