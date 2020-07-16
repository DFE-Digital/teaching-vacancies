require 'get_subject_name'

class HiringStaff::Vacancies::JobSpecificationController < HiringStaff::Vacancies::ApplicationController
  include GetSubjectName

  before_action :set_up_url
  before_action :set_up_form, only: %i[create update]

  include FirstStepFormConcerns

  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(form_params, @vacancy)
  end

  def show
    if @vacancy.present?
      @form = JobSpecificationForm.new(@vacancy.attributes)
    elsif session[:vacancy_attributes].present?
      @form = JobSpecificationForm.new(session[:vacancy_attributes])
    else
      @form = JobSpecificationForm.new(school_id: current_school.id)
    end
  end

  def create
    store_vacancy_attributes(@form.vacancy.attributes)

    if params[:commit] == I18n.t('buttons.save_and_return_later')
      return save_vacancy_as_draft
    elsif @form.complete_and_valid?
      session_vacancy_id ? update_vacancy(form_params) : save_vacancy_without_validation(@form.vacancy)
      store_vacancy_attributes(@form.vacancy.attributes)
      return redirect_to_next_step_if_continue(@vacancy&.id.present? ? @vacancy.id : session_vacancy_id)
    end

    render :show
  end

  def update
    if @form.valid?
      remove_subject_fields(@vacancy) unless @vacancy.subjects.nil?
      update_vacancy(form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    end


    render :show
  end

  private

  def form_submission_path(vacancy_id = nil)
    vacancy_id.present? ? organisation_job_job_specification_path(vacancy_id) : job_specification_organisation_job_path
  end

  def form_class
    JobSpecificationForm
  end

  def form_params
    strip_empty_checkboxes(:job_specification_form, [:working_patterns, :job_roles, :subjects])
    params.require(:job_specification_form)
          .permit(:state, :job_title,
                  job_roles: [], working_patterns: [], subjects: [])
          .merge(completed_step: current_step)
  end

  def save_vacancy_without_validation(vacancy)
    vacancy.school_id = current_school.id
    vacancy.send :set_slug
    save_form_params_on_vacancy_without_validation(vacancy)
  end

  def next_step
    organisation_job_pay_package_path(@vacancy&.id.present? ? @vacancy.id : session_vacancy_id)
  end

  def remove_subject_fields(vacancy)
    @vacancy.subject = nil
    @vacancy.first_supporting_subject = nil
    @vacancy.second_supporting_subject = nil
  end

  def save_vacancy_as_draft
    if @form.vacancy.job_title.present?
      save_vacancy_without_validation(@form.vacancy)
      redirect_to_draft(
        @form.vacancy.id,
        @form.vacancy.job_title
      )
    else
      redirect_to jobs_with_type_organisation_path('draft')
    end
  end
end
