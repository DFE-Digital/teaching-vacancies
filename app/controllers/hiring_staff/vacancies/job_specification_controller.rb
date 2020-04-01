require 'persist_nqt_job_role'

class HiringStaff::Vacancies::JobSpecificationController < HiringStaff::Vacancies::ApplicationController
  include PersistNQTJobRole

  def new
    @job_specification_form = JobSpecificationForm.new(school_id: current_school.id)
    return if session[:current_step].blank?

    @job_specification_form = JobSpecificationForm.new(session[:vacancy_attributes])
    @job_specification_form.valid?
  end

  def create
    @job_specification_form = JobSpecificationForm.new(job_specification_form_params)
    store_vacancy_attributes(@job_specification_form.vacancy.attributes)

    if @job_specification_form.valid?
      vacancy = session_vacancy_id ? update_vacancy(job_specification_form_params) : save_vacancy_without_validation
      store_vacancy_attributes(@job_specification_form.vacancy.attributes)
      redirect_to_next_step(vacancy)
    else
      session[:current_step] = :step_1 if session[:current_step].blank?
      redirect_to job_specification_school_job_path(anchor: 'errors')
    end
  end

  def edit
    vacancy_attributes = source_update? ? session[:vacancy_attributes] : retrieve_job_from_db

    @job_specification_form = JobSpecificationForm.new(vacancy_attributes)
    @job_specification_form.valid?
  end

  def update
    vacancy = current_school.vacancies.published.find(vacancy_id)
    @job_specification_form = JobSpecificationForm.new(job_specification_form_params)
    @job_specification_form.id = vacancy.id

    if @job_specification_form.valid?
      reset_session_vacancy!
      update_vacancy(job_specification_form_params, vacancy)
      update_google_index(vacancy) if vacancy.listed?
      redirect_to edit_school_job_path(vacancy.id), success: I18n.t('messages.jobs.updated')
    else
      store_vacancy_attributes(@job_specification_form.vacancy.attributes)
      redirect_to edit_school_job_job_specification_path(vacancy.id,
                                                         anchor: 'errors',
                                                         source: 'update')
    end
  end

  private

  def job_specification_form_params
    persist_nqt_job_role_to_nqt_attribute(:job_specification_form)
    params.require(:job_specification_form)
          .permit(:job_title, :job_description, :leadership_id,
                  :subject_id,
                  :starts_on_dd, :starts_on_mm,
                  :starts_on_yyyy, :ends_on_dd, :ends_on_mm, :ends_on_yyyy,
                  :flexible_working, :newly_qualified_teacher,
                  :first_supporting_subject_id, :second_supporting_subject_id,
                  working_patterns: [], job_roles: []).merge(completed_step: current_step)
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

  def called_from_update_method
    params[:source]&.eql?('update')
  end
end
