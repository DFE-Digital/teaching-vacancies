class HiringStaff::Vacancies::PublishController < HiringStaff::Vacancies::ApplicationController
  def create
    vacancy = Vacancy.find(vacancy_id)

    if PublishVacancy.new(vacancy: vacancy).call
      Auditor::Audit.new(vacancy, 'vacancy.publish', current_session_id).log
      reset_session_vacancy!
      redirect_to school_job_summary_path(vacancy.id)
    else
      redirect_to review_path(vacancy), notice: I18n.t('errors.jobs.unable_to_publish')
    end
  end

  private

  def vacancy_id
    params.permit(:job_id)[:job_id]
  end
end
