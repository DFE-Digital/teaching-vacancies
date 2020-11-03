class HiringStaff::Vacancies::JobSpecificationController < HiringStaff::Vacancies::ApplicationController
  before_action :set_up_url
  before_action :set_up_previous_step_path, only: %i[show]
  before_action only: %i[create update] do
    set_up_form(JobSpecificationForm)
  end
  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(form_params, @vacancy)
  end

  def show
    attributes = @vacancy.present? ? @vacancy.attributes : (session[:vacancy_attributes] || {})
    @form = JobSpecificationForm.new(attributes.symbolize_keys)
  end

  def create
    store_vacancy_attributes(@form.vacancy.attributes)

    if params[:commit] == I18n.t("buttons.save_and_return_later")
      save_vacancy_as_draft
    elsif @form.valid?
      session_vacancy_id ? update_vacancy(form_params) : save_vacancy_without_validation
      redirect_to_next_step_if_continue(@vacancy&.persisted? ? @vacancy.id : session_vacancy_id)
    else
      render :show
    end
  end

  def update
    if @form.valid?
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
    strip_empty_checkboxes(%i[working_patterns job_roles subjects], :job_specification_form)
    append_suitable_for_nqts_to_job_roles
    params.require(:job_specification_form)
          .permit(:state, :job_title, :suitable_for_nqt,
                  job_roles: [], working_patterns: [], subjects: [])
          .merge(completed_step: current_step)
  end

  def append_suitable_for_nqts_to_job_roles
    if params[:job_specification_form][:suitable_for_nqt] == "yes"
      params[:job_specification_form][:job_roles] |= [:nqt_suitable]
    end
  end

  def save_vacancy_as_draft
    if @form.vacancy.job_title.present?
      save_vacancy_without_validation
      redirect_to_draft(@form.vacancy.job_title)
    else
      redirect_to jobs_with_type_organisation_path("draft")
    end
  end

  def save_vacancy_without_validation
    set_job_location_fields
    set_organisation_vacancies
    @form.vacancy.send :set_slug
    @form.vacancy.status = :draft
    @form.vacancy.assign_attributes(session[:vacancy_attributes].except("organisation_id", "organisation_ids"))
    Auditor::Audit.new(@form.vacancy, "vacancy.create", current_session_id).log do
      @form.vacancy.save(validate: false)
    end
    store_vacancy_attributes(@form.vacancy.attributes)
    @form.vacancy
  end

  def set_organisation_vacancies
    if current_organisation.is_a?(School)
      @form.vacancy.organisation_vacancies.build(organisation: current_organisation)
    elsif current_organisation.is_a?(SchoolGroup)
      organisation_ids = [session[:vacancy_attributes]["organisation_ids"],
                          [session[:vacancy_attributes]["organisation_id"]]].compact.reduce([], :concat)
      organisation_ids.each do |organisation_id|
        @form.vacancy.organisation_vacancies.build(organisation_id: organisation_id)
      end
    end
  end

  def set_job_location_fields
    if current_organisation.is_a?(School)
      @form.vacancy.job_location = "at_one_school"
      @form.vacancy.readable_job_location = readable_job_location("at_one_school", school_name: current_organisation.name)
    end
  end

  def next_step
    organisation_job_pay_package_path(@vacancy&.persisted? ? @vacancy.id : session_vacancy_id)
  end

  def set_up_previous_step_path
    job_location = @vacancy&.job_location.presence || session[:vacancy_attributes]&.[]("job_location")
    if current_organisation.is_a?(School)
      @previous_step_path = organisation_path
    elsif %w[at_one_school at_multiple_schools].include?(job_location)
      @previous_step_path = @vacancy.present? ? organisation_job_schools_path(@vacancy.id) : schools_organisation_job_path
    elsif job_location == "central_office"
      @previous_step_path = @vacancy.present? ? organisation_job_job_location_path(@vacancy.id) : job_location_organisation_job_path
    end
  end
end
