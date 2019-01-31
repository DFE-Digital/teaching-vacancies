class HiringStaff::Vacancies::CopyController < HiringStaff::Vacancies::ApplicationController
  def new
    vacancy = Vacancy.find(vacancy_id)
    @school = school
    @copy_form = CopyVacancyForm.new(vacancy: vacancy)
  end

  def create
    vacancy = Vacancy.find(vacancy_id)
    copy_form = CopyVacancyForm.new(vacancy: vacancy).apply_changes(copy_form_params)

    if copy_form.vacancy.valid?
      new_vacancy = CopyVacancy.new(original: vacancy, new: copy_form.vacancy).call
      Auditor::Audit.new(new_vacancy, 'vacancy.copy', current_session_id).log
      redirect_to review_path(new_vacancy)
    else
      @school = school
      @copy_form = CopyVacancyForm.new(vacancy: vacancy)
      render 'new'
    end
  end

  private

  def copy_form_params
    params.require(:copy_vacancy_form).permit(:job_title,
                                              :starts_on_dd, :starts_on_mm, :starts_on_yyyy,
                                              :ends_on_dd, :ends_on_mm, :ends_on_yyyy,
                                              :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
                                              :publish_on_dd, :publish_on_mm, :publish_on_yyyy)
  end

  def vacancy_id
    params.permit(:job_id)[:job_id]
  end
end
