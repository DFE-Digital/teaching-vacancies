class HiringStaff::Vacancies::CopyController < HiringStaff::Vacancies::ApplicationController
  def create
    vacancy = Vacancy.find(vacancy_id)
    vacancy_copy = CopyVacancy.new(vacancy: vacancy).copy
    if vacancy_copy.save
      Auditor::Audit.new(vacancy_copy, 'vacancy.copy', current_session_id).log
      redirect_to review_path(vacancy_copy)
    else
      redirect_to school_path, notice: I18n.t('errors.jobs.unable_to_copy')
    end
  end

  private

  def vacancy_id
    params.permit(:job_id)[:job_id]
  end
end
