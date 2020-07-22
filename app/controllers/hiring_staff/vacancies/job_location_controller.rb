class HiringStaff::Vacancies::JobLocationController < HiringStaff::Vacancies::ApplicationController
  before_action :verify_school_group
  before_action :set_up_url
  before_action only: %i[create update] do
    set_up_form(JobLocationForm)
  end

  def show
    attributes = @vacancy.present? ? @vacancy.attributes : session[:vacancy_attributes]
    if attributes.present?
      @form = JobLocationForm.new(attributes)
    else
      @form = JobLocationForm.new(school_group_id: current_school_group.id)
    end
  end

  def create
    store_vacancy_attributes(@form.vacancy.attributes)

    if @form.valid?
      redirect_to_next_step_if_continue(@vacancy&.persisted? ? @vacancy.id : session_vacancy_id)
    else
      render :show
    end
  end

  def update
    if @form.valid?
      @vacancy.update(school_id: nil) if @form.job_location == 'central_office'
      update_vacancy(form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      redirect_to_school_selection_or_next_step
    else
      render :show
    end
  end

  private

  def form_submission_path(vacancy_id)
    vacancy_id.present? ? organisation_job_job_location_path(vacancy_id) : job_location_organisation_job_path
  end

  def form_params
    (params[:job_location_form] || params).permit(:state, :job_location).merge(completed_step: current_step)
  end

  def next_step
    vacancy_id = @vacancy&.persisted? ? @vacancy.id : session_vacancy_id
    if @form.job_location == 'at_one_school'
      vacancy_id.present? ? organisation_job_school_path(vacancy_id) : school_organisation_job_path
    elsif @form.job_location == 'central_office'
      vacancy_id.present? ?
        organisation_job_job_specification_path(vacancy_id) : job_specification_organisation_job_path
    end
  end

  def redirect_to_school_selection_or_next_step
    if session[:current_step].eql?(:review) && @form.job_location == 'at_one_school'
      redirect_to organisation_job_school_path(@vacancy.id)
    else
      redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    end
  end
end
