require 'get_subject_name'

class HiringStaff::Vacancies::JobSpecificationController < HiringStaff::Vacancies::ApplicationController
  include GetSubjectName

  before_action :set_up_url
  before_action only: %i[create update] do
    set_up_form(JobSpecificationForm)
  end
  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(form_params, @vacancy)
  end

  def show
    attributes = @vacancy.present? ? @vacancy.attributes : session[:vacancy_attributes]
    if attributes.present?
      @form = JobSpecificationForm.new(attributes)
    else
      @form = JobSpecificationForm.new(school_id: current_school.id)
    end
  end

  def create
    store_vacancy_attributes(@form.vacancy.attributes)

    if params[:commit] == I18n.t('buttons.save_and_return_later')
      save_vacancy_as_draft
    elsif @form.valid?
      session_vacancy_id ? update_vacancy(form_params) : save_vacancy_without_validation
      redirect_to_next_step_if_continue(@vacancy&.id.present? ? @vacancy.id : session_vacancy_id)
    else
      render :show
    end
  end

  def update
    if @form.valid?
      remove_subject_fields(@vacancy) unless @vacancy.subjects.nil?
      update_vacancy(form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    else
      render :show
    end
  end

  private

  def form_submission_path(vacancy_id)
    vacancy_id.present? ? organisation_job_job_specification_path(vacancy_id) : job_specification_organisation_job_path
  end

  def form_params
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
    if @form.vacancy.job_title.present?
      save_vacancy_without_validation
      redirect_to_draft(@form.vacancy.id, @form.vacancy.job_title)
    else
      redirect_to jobs_with_type_organisation_path('draft')
    end
  end

  def save_vacancy_without_validation
    set_school_or_school_group_id
    @form.vacancy.send :set_slug
    @form.vacancy.status = :draft
    @form.vacancy.assign_attributes(session[:vacancy_attributes])
    Auditor::Audit.new(@form.vacancy, 'vacancy.create', current_session_id).log do
      @form.vacancy.save(validate: false)
    end
    store_vacancy_attributes(@form.vacancy.attributes)
    @form.vacancy
  end

  def set_school_or_school_group_id
    if current_organisation.is_a?(School)
      @form.vacancy.school_id = current_organisation.id
    elsif current_organisation.is_a?(SchoolGroup)
      @form.vacancy.school_group_id = current_organisation.id
    end
  end

  def next_step
    organisation_job_pay_package_path(@vacancy&.id.present? ? @vacancy.id : session_vacancy_id)
  end
end
