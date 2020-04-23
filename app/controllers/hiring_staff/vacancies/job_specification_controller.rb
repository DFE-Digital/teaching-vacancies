require 'persist_nqt_job_role'

class HiringStaff::Vacancies::JobSpecificationController < HiringStaff::Vacancies::ApplicationController
  include PersistNQTJobRole

  before_action :set_up_job_specification_form, only: %i[create update]

  def show
    if @vacancy.present?
      @job_specification_form = JobSpecificationForm.new(@vacancy.attributes)
    elsif session[:vacancy_attributes].present?
      @job_specification_form = JobSpecificationForm.new(session[:vacancy_attributes])
    else
      @job_specification_form = JobSpecificationForm.new(school_id: current_school.id)
    end
  end

  def create
    store_vacancy_attributes(@job_specification_form.vacancy.attributes)

    if @job_specification_form.complete_and_valid?
      session_vacancy_id ? update_vacancy(job_specification_form_params) : save_vacancy_without_validation
      store_vacancy_attributes(@job_specification_form.vacancy.attributes)
      return redirect_to_next_step_if_save_and_continue
    end

    render :show
  end

  def update
    if @job_specification_form.complete_and_valid?
      reset_session_vacancy!
      update_vacancy(job_specification_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_save_and_continue
    end

    render :show
  end

  private

  def set_up_job_specification_form
    date_errors = convert_multiparameter_attributes_to_dates(:job_specification_form, [:starts_on, :ends_on])
    @job_specification_form = JobSpecificationForm.new(job_specification_form_params)
    add_errors_to_form(date_errors, @job_specification_form)
  end

  def job_specification_form_params
    persist_nqt_job_role_to_nqt_attribute(:job_specification_form)
    strip_empty_checkboxes(:job_specification_form, [:working_patterns, :job_roles])
    params.require(:job_specification_form)
          .permit(:job_title,
                  :subject_id, :first_supporting_subject_id, :second_supporting_subject_id,
                  :starts_on, :ends_on,
                  :newly_qualified_teacher,
                  working_patterns: [], job_roles: [])
          .merge(completed_step: current_step)
  end

  def save_vacancy_without_validation
    # TODO remove after migration to remove minimum salary column
    @job_specification_form.vacancy.minimum_salary = ''
    @job_specification_form.vacancy.school_id = current_school.id
    @job_specification_form.vacancy.send :set_slug
    @job_specification_form.vacancy.status = :draft
    Auditor::Audit.new(@job_specification_form.vacancy, 'vacancy.create', current_session_id).log do
      @job_specification_form.vacancy.save(validate: false)
    end
    @job_specification_form.vacancy
  end

  def next_step
    school_job_pay_package_path(session_vacancy_id)
  end

  def redirect_to_next_step_if_save_and_continue
    if params[:commit] == I18n.t('buttons.save_and_continue')
      redirect_to_next_step(@vacancy)
    elsif params[:commit] == I18n.t('buttons.update_job')
      redirect_to edit_school_job_path(@vacancy.id), success: I18n.t('messages.jobs.updated')
    end
  end
end
