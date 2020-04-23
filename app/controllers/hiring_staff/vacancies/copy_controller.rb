require 'persist_nqt_job_role'

class HiringStaff::Vacancies::CopyController < HiringStaff::Vacancies::ApplicationController
  include PersistNQTJobRole

  def new
    @copy_form = CopyVacancyForm.new(vacancy: @vacancy)
  end

  def create
    @copy_form = CopyVacancyForm.new(vacancy: @vacancy)
    date_errors = convert_multiparameter_attributes_to_dates(
      :copy_vacancy_form, [:starts_on, :ends_on, :publish_on, :expires_on]
    )
    @proposed_vacancy = @copy_form.apply_changes!(copy_form_params)
    @copy_form.update_expiry_time(@proposed_vacancy, params.require(:copy_vacancy_form))
    add_errors_to_form(date_errors, @copy_form)

    if valid_copy_form?
      new_vacancy = CopyVacancy.new(@proposed_vacancy).call
      Auditor::Audit.new(new_vacancy, 'vacancy.copy', current_session_id).log
      return redirect_to review_path(new_vacancy)
    end

    render :new
  end

  private

  def valid_copy_form?
    @copy_form.complete_and_valid? && @proposed_vacancy.valid?
  end

  def copy_form_params
    persist_nqt_job_role_to_nqt_attribute(:copy_vacancy_form)
    strip_empty_checkboxes(:copy_vacancy_form, [:job_roles])
    params.require(:copy_vacancy_form).permit(:job_title, :about_school,
                                              :starts_on, :ends_on,
                                              :publish_on, :expires_on,
                                              :expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem,
                                              :newly_qualified_teacher, job_roles: [])
  end
end
