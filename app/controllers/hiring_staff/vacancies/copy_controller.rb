class HiringStaff::Vacancies::CopyController < HiringStaff::Vacancies::ApplicationController
  def new
    @copy_form = CopyVacancyForm.new(vacancy: @vacancy)
  end

  def create
    @copy_form = CopyVacancyForm.new(vacancy: @vacancy)
    date_errors = convert_multiparameter_attributes_to_dates(
      :copy_vacancy_form, [:publish_on, :expires_on, :starts_on]
    )
    @proposed_vacancy = @copy_form.apply_changes!(copy_form_params)
    @copy_form.update_expiry_time(@proposed_vacancy, params.require(:copy_vacancy_form))
    add_errors_to_form(date_errors, @copy_form)

    if valid_copy_form?
      new_vacancy = CopyVacancy.new(@proposed_vacancy).call
      Auditor::Audit.new(new_vacancy, 'vacancy.copy', current_session_id).log
      return redirect_to school_job_review_path(new_vacancy.id)
    end

    render :new
  end

  private

  def valid_copy_form?
    @copy_form.complete_and_valid? && @proposed_vacancy.valid?
  end

  def copy_form_params
    params.require(:copy_vacancy_form).permit(:state, :job_title, :about_school,
                                              :publish_on, :expires_on, :starts_on,
                                              :expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem)
  end
end
