class HiringStaff::Vacancies::PublishController < HiringStaff::Vacancies::ApplicationController
  def create
    vacancy = Vacancy.find(vacancy_id)
    return redirect_to school_job_path(vacancy.id), notice: I18n.t('jobs.already_published') if vacancy.published?

    if PublishVacancy.new(vacancy: vacancy).call
      Auditor::Audit.new(vacancy, 'vacancy.publish', current_session_id).log
      UpdateVacancySpreadsheetJob.perform_later(vacancy.id)
      update_google_index(vacancy) if vacancy.listed?
      reset_session_vacancy!
      redirect_to school_job_summary_path(vacancy.id)
    else
      redirect_to review_path_with_errors(vacancy), notice: I18n.t('errors.jobs.unable_to_publish')
    end
  end

  private

  def vacancy_id
    params.permit(:job_id)[:job_id]
  end
end
