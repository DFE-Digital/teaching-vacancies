class HiringStaff::Vacancies::PublishController < HiringStaff::Vacancies::ApplicationController
  def create
    vacancy = Vacancy.find(vacancy_id)

    if PublishVacancy.new(vacancy: vacancy).call
      Auditor::Audit.new(vacancy, 'vacancy.publish', current_session_id).log
      update_google_index(vacancy) if vacancy.listed?
      reset_session_vacancy!
      redirect_to school_job_summary_path(vacancy.id)
    else
      skip_to_change_publish_on_date(vacancy.id) && return if vacancy.publish_on.past?

      redirect_to review_path(vacancy), notice: I18n.t('errors.jobs.unable_to_publish')
    end
  end

  private

  def skip_to_change_publish_on_date(vacancy_id)
    redirect_to edit_school_job_application_details_path(vacancy_id,
                                                         anchor: 'errors',
                                                         source: 'review')
  end

  def vacancy_id
    params.permit(:job_id)[:job_id]
  end
end
