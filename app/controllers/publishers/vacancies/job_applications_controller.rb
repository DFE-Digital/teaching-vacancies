class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::ApplicationController
  helper_method :job_application, :vacancy

  private

  def job_application
    @job_application ||= vacancy.job_applications.submitted.find(params[:id])
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.listed.find(params[:job_id])
  end
end
