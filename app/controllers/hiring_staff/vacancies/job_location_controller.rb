class HiringStaff::Vacancies::JobLocationController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_school_group_user_flag_on
  before_action :set_up_url
  before_action :set_up_job_location_options
  before_action :set_up_job_location_form, only: %i[create update]

  def show
    if @vacancy.present?
      @job_location_form = JobLocationForm.new(@vacancy.attributes)
    elsif session[:vacancy_attributes].present?
      @job_location_form = JobLocationForm.new(session[:vacancy_attributes])
    else
      @job_location_form = JobLocationForm.new
    end
  end

  def create
    store_vacancy_attributes(@job_location_form.vacancy.attributes)

    if @job_location_form.complete_and_valid?
      session_vacancy_id ? update_vacancy(job_location_form_params) : save_vacancy_without_validation
      store_vacancy_attributes(@job_location_form.vacancy.attributes)
      return redirect_to_next_step_if_save_and_continue(@vacancy&.id.present? ? @vacancy.id : session_vacancy_id)
    end

    render :show
  end

  def update
    @job_location_form = JobLocationForm.new(job_location_form_params)

    if @job_location_form.valid?
      store_vacancy_attributes(@job_location_form.vacancy.attributes)
      update_vacancy(job_location_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_school_selection_or_next_step
    end

    render :show
  end

  private

  def set_up_url
    @job_location_url_method = @vacancy&.id.present? ? 'patch' : 'post'
    @job_location_url = @vacancy&.id.present? ?
      school_job_job_location_path(@vacancy.id) : job_location_school_job_path(school_group_id: current_school_group.id)
  end

  def set_up_job_location_options
    @job_location_options = [
      ['at_one_school', I18n.t('helpers.fieldset.job_location_form.job_location_options.at_one_school')],
      ['central_office', I18n.t('helpers.fieldset.job_location_form.job_location_options.central_office')]]
  end

  def set_up_job_location_form
    @job_location_form = JobLocationForm.new(job_location_form_params)
  end

  def job_location_form_params
    (params[:job_location_form] || params)
      .permit(:state, :job_location)
      .merge(completed_step: current_step)
  end

  def next_step
    vacancy_id = @vacancy&.id.present? ? @vacancy.id : session_vacancy_id
    if @job_location_form.job_location == 'at_one_school'
      # TODO: make this path exist
      school_job_school_path(vacancy_id)
    elsif @job_location_form.job_location == 'central_office'
      school_job_job_specification_path(vacancy_id)
    end
  end

  def redirect_to_school_selection_or_next_step
    if session[:current_step].eql?(:review) && @job_location_form.job_location == 'at_one_school'
      redirect_to school_job_school_path(@vacancy.id)
    else
      redirect_to_next_step_if_save_and_continue(@vacancy.id, @vacancy.job_title)
    end
  end

  def save_vacancy_without_validation
    if job_location_form_params[:job_location] == 'central_office'
      @job_location_form.vacancy.school_group_id = current_school_group.id
    end
    @job_location_form.vacancy.send :set_slug
    @job_location_form.vacancy.status = :draft
    Auditor::Audit.new(@job_location_form.vacancy, 'vacancy.create', current_session_id).log do
      @job_location_form.vacancy.save(validate: false)
    end
    @job_location_form.vacancy
  end

  def redirect_unless_school_group_user_flag_on
    redirect_to job_specification_school_job_path(request.parameters) unless SchoolGroupJobsFeature.enabled?
  end
end
