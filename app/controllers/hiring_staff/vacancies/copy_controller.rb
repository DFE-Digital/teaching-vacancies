class HiringStaff::Vacancies::CopyController < HiringStaff::Vacancies::ApplicationController
  before_action :set_up_copy_form, only: %i[create]

  def new
    reset_date_fields if @vacancy.publish_on.past?
    @copy_form = CopyVacancyForm.new(@vacancy.attributes.symbolize_keys)
  end

  def create
    if @copy_form.complete_and_valid?
      new_vacancy = CopyVacancy.new(@vacancy).call
      update_vacancy(@copy_form.params_to_save, new_vacancy)
      update_google_index(new_vacancy) if new_vacancy.listed?
      Auditor::Audit.new(new_vacancy, 'vacancy.copy', current_session_id).log
      redirect_to organisation_job_review_path(new_vacancy.id)
    else
      add_errors_to_form(@date_errors, @copy_form)
      render :new
    end
  end

private

  def copy_form_params
    params.require(:copy_vacancy_form).permit(:state, :job_title, :publish_on, :expires_on, :starts_on,
                                              :expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem)
  end

  def set_up_copy_form
    @date_errors = convert_multiparameter_attributes_to_dates(
      :copy_vacancy_form, %i[publish_on expires_on starts_on]
    )
    @copy_form = CopyVacancyForm.new(copy_form_params)
  end

  def reset_date_fields
    @vacancy.expires_on = nil
    @vacancy.starts_on = nil
    @vacancy.publish_on = nil
  end
end
