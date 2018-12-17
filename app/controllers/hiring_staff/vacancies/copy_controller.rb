class HiringStaff::Vacancies::CopyController < HiringStaff::Vacancies::ApplicationController
  def create
    vacancy = Vacancy.find(vacancy_id)
    vacancy_copy = vacancy.dup
    update_fields(vacancy_copy)
    if vacancy_copy.save
      Auditor::Audit.new(vacancy_copy, 'vacancy.copy', current_session_id).log
      redirect_to review_path(vacancy_copy)
    else
      redirect_to school_path, notice: I18n.t('errors.jobs.unable_to_copy')
    end
  end

  private

  def update_fields(vacancy)
    vacancy.job_title = "#{I18n.t('jobs.copy_of')} #{vacancy.job_title}"
    vacancy.status = :draft
    vacancy.publish_on = Time.zone.today if vacancy.publish_on <= Time.zone.today
    vacancy
  end

  def vacancy_id
    params.permit(:job_id)[:job_id]
  end
end
