class Publishers::Vacancies::JobApplications::BaseController < Publishers::Vacancies::BaseController
  helper_method :job_application, :vacancy

  def job_application
    @job_application ||= vacancy.job_applications.find(params[:job_application_id] || params[:id])
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies
                                     .listed
                                     .find(params[:job_id])
  end
end
