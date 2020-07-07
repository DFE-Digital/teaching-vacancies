require 'get_subject_name'

class HiringStaff::Vacancies::JobSpecificationController < HiringStaff::Vacancies::ApplicationController
  include GetSubjectName

  before_action :set_up_url
  before_action :set_up_job_specification_form, only: %i[create update]

  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(job_specification_form_params, @vacancy)
  end

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

    if params[:commit] == I18n.t('buttons.save_and_return_later')
      return save_vacancy_as_draft
    elsif @job_specification_form.complete_and_valid?
      session_vacancy_id ? update_vacancy(job_specification_form_params) : save_vacancy_without_validation
      store_vacancy_attributes(@job_specification_form.vacancy.attributes)
      return redirect_to_next_step_if_save_and_continue(@vacancy&.id.present? ? @vacancy.id : session_vacancy_id)
    end

    render :show
  end

  def update
    if @job_specification_form.valid?
      remove_subject_fields(@vacancy) unless @vacancy.subjects.nil?
      update_vacancy(job_specification_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_save_and_continue(@vacancy.id, @vacancy.job_title)
    end

    render :show
  end

  private

  def set_up_url
    @job_specification_url_method = @vacancy&.id.present? ? 'patch' : 'post'
    @job_specification_url = @vacancy&.id.present? ?
      organisation_job_job_specification_path(@vacancy.id) :
      job_specification_organisation_job_path(school_id: current_school.id)
  end

  def set_up_job_specification_form
    @job_specification_form = JobSpecificationForm.new(job_specification_form_params)
  end

  def job_specification_form_params
    strip_empty_checkboxes(:job_specification_form, [:working_patterns, :job_roles, :subjects])
    params.require(:job_specification_form)
          .permit(:state, :job_title,
                  job_roles: [], working_patterns: [], subjects: [])
          .merge(completed_step: current_step)
  end

  def remove_subject_fields(vacancy)
    @vacancy.subject = nil
    @vacancy.first_supporting_subject = nil
    @vacancy.second_supporting_subject = nil
  end

  def save_vacancy_as_draft
    if @job_specification_form.vacancy.job_title.present?
      save_vacancy_without_validation
      redirect_to_draft(
        @job_specification_form.vacancy.id,
        @job_specification_form.vacancy.job_title
      )
    else
      redirect_to jobs_with_type_organisation_path('draft')
    end
  end

  def save_vacancy_without_validation
    @job_specification_form.vacancy.school_id = current_school.id
    @job_specification_form.vacancy.send :set_slug
    @job_specification_form.vacancy.status = :draft
    Auditor::Audit.new(@job_specification_form.vacancy, 'vacancy.create', current_session_id).log do
      @job_specification_form.vacancy.save(validate: false)
    end
    @job_specification_form.vacancy
  end

  def next_step
    organisation_job_pay_package_path(@vacancy&.id.present? ? @vacancy.id : session_vacancy_id)
  end
end
