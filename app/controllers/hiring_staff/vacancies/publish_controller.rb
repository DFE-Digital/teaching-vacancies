class HiringStaff::Vacancies::PublishController < HiringStaff::Vacancies::ApplicationController
  def create
    vacancy = Vacancy.find(vacancy_id)

    if PublishVacancy.new(vacancy: vacancy).call
      Auditor::Audit.new(vacancy, 'vacancy.publish', current_session_id).log
      reset_session_vacancy!
      redirect_to school_vacancy_summary_path(school, vacancy.id)
    else
      redirect_to review_path(vacancy), notice: I18n.t('errors.vacancies.unable_to_publish')
    end
  end

  private

  def vacancy_id
    params.permit(:vacancy_id)[:vacancy_id]
  end
end
