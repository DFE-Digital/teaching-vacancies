class HiringStaff::Vacancies::JobLocationController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_school_group_user_flag_on
  before_action :set_up_url
  before_action only: %i[create update] do
    set_up_form(JobLocationForm)
  end

  def show
    if @vacancy.present?
      @form = JobLocationForm.new(@vacancy.attributes)
    elsif session[:vacancy_attributes].present?
      @form = JobLocationForm.new(session[:vacancy_attributes])
    else
      @form = JobLocationForm.new(school_group_id: current_school_group.id)
    end
  end

  def create
    store_vacancy_attributes(@form.vacancy.attributes)

    if @form.complete_and_valid?
      session_vacancy_id ? update_vacancy(form_params) : save_vacancy_without_validation
      store_vacancy_attributes(@form.vacancy.attributes)
      return redirect_to_next_step_if_continue(@vacancy&.id.present? ? @vacancy.id : session_vacancy_id)
    end

    render :show
  end

  def update
    if @form.valid?
      store_vacancy_attributes(@form.vacancy.attributes)
      update_vacancy(form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_school_selection_or_next_step
    end

    render :show
  end

  private

  def form_submission_path(vacancy_id = nil)
    vacancy_id.present? ? organisation_job_job_location_path(vacancy_id) : job_location_organisation_job_path
  end

  def form_params
    (params[:job_location_form] || params)
      .permit(:state, :job_location)
      .merge(completed_step: current_step)
  end

  def save_vacancy_without_validation
    @form.vacancy.school_group_id = current_school_group.id
    save_form_params_on_vacancy_without_validation
  end

  def next_step
    vacancy_id = @vacancy&.id.present? ? @vacancy.id : session_vacancy_id
    if @form.job_location == 'at_one_school'
      organisation_job_school_path(vacancy_id)
    elsif @form.job_location == 'central_office'
      organisation_job_job_specification_path(vacancy_id)
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
