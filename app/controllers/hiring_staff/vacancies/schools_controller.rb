class HiringStaff::Vacancies::SchoolsController < HiringStaff::Vacancies::ApplicationController
  include OrganisationHelper

  before_action :verify_school_group
  before_action :set_up_url
  before_action :set_up_previous_step_path
  before_action :set_multiple_schools
  before_action :set_organisation_options
  before_action only: %i[create update] do
    set_up_form(SchoolsForm)
  end

  def show
    attributes = @vacancy.present? ? @vacancy.attributes : session[:vacancy_attributes]
    return redirect_to next_step if job_location == 'central_office'
    @form = SchoolsForm.new(attributes.symbolize_keys)
  end

  def create
    @form.vacancy.readable_job_location = readable_job_location(job_location, school_name: school&.name,
                                                                schools_count: @form.organisation_ids&.count)
    store_vacancy_attributes(@form.vacancy.attributes)
    session[:vacancy_attributes]['organisation_id'] = @form.organisation_id
    session[:vacancy_attributes]['organisation_ids'] = @form.organisation_ids
    if @form.valid?
      redirect_to_next_step_if_continue(@vacancy&.persisted? ? @vacancy.id : session_vacancy_id)
    else
      render :show
    end
  end

  def update
    if @form.valid?
      @vacancy.update(readable_job_location: readable_job_location(job_location, school_name: school&.name,
                                                                   schools_count: @form.organisation_ids&.count))
      organisation_ids = [@form.organisation_ids, [@form.organisation_id]].compact.reduce([], :concat)
      set_organisations(@vacancy, organisation_ids)
      update_google_index(@vacancy) if @vacancy.listed?
      redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    else
      render :show
    end
  end

  private

  def form_submission_path(vacancy_id = nil)
    vacancy_id.present? ? organisation_job_schools_path(vacancy_id) : schools_organisation_job_path
  end

  def form_params
    strip_empty_checkboxes(:schools_form, [:organisation_ids])
    params.require(:schools_form)
          .permit(:state, :organisation_id, organisation_ids: [])
          .merge(completed_step: current_step, job_location: job_location)
  end

  def next_step
    vacancy_id = @vacancy&.persisted? ? @vacancy.id : session_vacancy_id
    vacancy_id.present? ? organisation_job_job_specification_path(@vacancy.id) : job_specification_organisation_job_path
  end

  def set_organisation_options
    @organisation_options = current_organisation.schools.order(:name).map do |school|
      OpenStruct.new({ id: school.id, name: school.name, address: full_address(school) })
    end
  end

  def set_multiple_schools
    @multiple_schools = job_location == 'at_multiple_schools'
  end

  def set_up_previous_step_path
    @previous_step_path = @vacancy.present? ?
      organisation_job_job_location_path(@vacancy.id) : job_location_organisation_job_path
  end

  def school
    current_organisation.schools.find(form_params[:organisation_id]) if form_params[:organisation_id].present?
  end

  def job_location
    @vacancy&.job_location.presence || session[:vacancy_attributes]['job_location']
  end
end
