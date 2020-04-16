require 'persist_nqt_job_role'

class HiringStaff::Vacancies::JobSpecificationController < HiringStaff::Vacancies::ApplicationController
  include PersistNQTJobRole

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
    @job_specification_form = JobSpecificationForm.new(job_specification_form_params)
    store_vacancy_attributes(@job_specification_form.vacancy.attributes)

    if @job_specification_form.valid?
      session_vacancy_id ? update_vacancy(job_specification_form_params) : save_vacancy_without_validation
      store_vacancy_attributes(@job_specification_form.vacancy.attributes)
      return redirect_to_next_step_if_save_and_continue
    end

    render :show
  end

  def update
    @job_specification_form = JobSpecificationForm.new(job_specification_form_params)

    if @job_specification_form.valid?
      reset_session_vacancy!
      update_vacancy(job_specification_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_save_and_continue
    end

    render :show
  end

  private

  def job_specification_form_params
    persist_nqt_job_role_to_nqt_attribute(:job_specification_form)
    convert_date('starts_on')
    convert_date('ends_on')
    strip_empty_checkboxes(:working_patterns)
    strip_empty_checkboxes(:job_roles)
    params.require(:job_specification_form)
          .permit(:job_title,
                  :subject_id, :first_supporting_subject_id, :second_supporting_subject_id,
                  :starts_on, :ends_on,
                  :newly_qualified_teacher,
                  working_patterns: [], job_roles: [])
          .merge(completed_step: current_step)
  end

  def convert_date(field)
    date_params = flatten_date_hash(
      params[:job_specification_form].extract!("#{field}(1i)", "#{field}(2i)", "#{field}(3i)"), field
    )
    params[:job_specification_form][field] = Date.new(*date_params) unless date_params.all?(0)
  end

  def flatten_date_hash(hash, field)
    %w(1 2 3).map { |i| hash["#{field}(#{i}i)"].to_i }
  end

  def strip_empty_checkboxes(field)
    params[:job_specification_form][field] = params[:job_specification_form][field]&.reject(&:blank?)
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
