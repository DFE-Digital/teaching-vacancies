class HiringStaff::Vacancies::SchoolController < HiringStaff::Vacancies::ApplicationController
  include OrganisationHelper

  before_action :verify_school_group
  before_action :set_up_url
  before_action :set_organisation_options, only: %i[show update]
  before_action only: %i[create update] do
    set_up_form(SchoolForm)
  end
  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(form_params, @vacancy)
  end

  def show
    attributes = @vacancy.present? ? @vacancy.attributes : session[:vacancy_attributes]
    return redirect_to next_step if attributes['job_location'] == 'central_office'
    @form = SchoolForm.new(attributes)
  end

  def create
    @form.vacancy.readable_job_location = readable_job_location(session[:vacancy_attributes]['job_location'])
    store_vacancy_attributes(@form.vacancy.attributes)
    session[:organisation_id] = school.id
    if @form.valid?
      redirect_to_next_step_if_continue(@vacancy&.persisted? ? @vacancy.id : session_vacancy_id)
    else
      render :show
    end
  end

  def update
    if @form.valid?
      @vacancy.update(readable_job_location: readable_job_location(@vacancy.job_location))
      set_organisations(@vacancy, school.id)
      update_google_index(@vacancy) if @vacancy.listed?
      redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    else
      render :show
    end
  end

  private

  def form_submission_path(vacancy_id = nil)
    vacancy_id.present? ? organisation_job_school_path(vacancy_id) : school_organisation_job_path
  end

  def form_params
    params.require(:school_form).permit(:state, :organisation_id).merge(completed_step: current_step)
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

  def school
    current_organisation.schools.find(form_params[:organisation_id])
  end

  def readable_job_location(job_location)
    school.name if job_location == 'at_one_school'
  end
end
