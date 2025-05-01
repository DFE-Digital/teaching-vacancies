class Publishers::Vacancies::JobApplications::BaseController < Publishers::Vacancies::BaseController
  before_action :set_vacancy

  helper_method :vacancy

  private

  attr_reader :vacancy

  def set_job_application
    @job_application = @vacancy.job_applications.find(params[:job_application_id] || params[:id])
  end

  def set_vacancy
    @vacancy = current_organisation.all_vacancies
                                     .listed
                                     .find(params[:job_id])
  end
end
