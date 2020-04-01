class HiringStaff::Vacancies::CopyController < HiringStaff::Vacancies::ApplicationController
  def new
    vacancy = Vacancy.find(vacancy_id)
    @copy_form = CopyVacancyForm.new(vacancy: vacancy)
  end

  def create
    old_vacancy = Vacancy.find(vacancy_id)
    @copy_form = CopyVacancyForm.new(vacancy: old_vacancy)
    proposed_vacancy = @copy_form.apply_changes!(copy_form_params)

    if proposed_vacancy.valid? && @copy_form.valid?
      @copy_form.update_expiry_time(proposed_vacancy, copy_form_params)
      new_vacancy = CopyVacancy.new(proposed_vacancy).call
      Auditor::Audit.new(new_vacancy, 'vacancy.copy', current_session_id).log
      redirect_to review_path(new_vacancy)
    else
      render 'new'
    end
  end

  private

  def copy_form_params
    persist_nqt_job_role_to_nqt_attribute
    params.require(:copy_vacancy_form).permit(:job_title,
                                              :starts_on_dd, :starts_on_mm, :starts_on_yyyy,
                                              :ends_on_dd, :ends_on_mm, :ends_on_yyyy,
                                              :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
                                              :expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem,
                                              :publish_on_dd, :publish_on_mm, :publish_on_yyyy,
                                              :newly_qualified_teacher, job_roles: [])
  end

  # Only necessary until changes to search are implemented
  # TODO remove after migration to remove newly qualified teacher column
  def persist_nqt_job_role_to_nqt_attribute
    job_roles = params.require(:copy_vacancy_form)[:job_roles]

    if job_roles && job_roles.include?(I18n.t('jobs.job_role_options.nqt_suitable'))
      params[:copy_vacancy_form][:newly_qualified_teacher] = true
    elsif job_roles
      params[:copy_vacancy_form][:newly_qualified_teacher] = false
    end
  end

  def vacancy_id
    params.permit(:job_id)[:job_id]
  end
end
