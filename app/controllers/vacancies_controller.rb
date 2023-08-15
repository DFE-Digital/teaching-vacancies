class VacanciesController < ApplicationController
  before_action :set_landing_page, only: %i[index]
  after_action :trigger_search_performed_event, only: %i[index]

  def index
    @vacancies_search = Search::VacancySearch.new(form.to_hash, sort: form.sort)
    @pagy, @vacancies = pagy(@vacancies_search.vacancies, count: @vacancies_search.total_count)

    set_search_coordinates
  end

  def show
    vacancy = Vacancy.listed.friendly.find(params[:id])
    @saved_job = current_jobseeker&.saved_jobs&.find_by(vacancy: vacancy)
    @job_application = current_jobseeker&.job_applications&.find_by(vacancy: vacancy)
    @invented_job_alert_search_criteria = Search::CriteriaInventor.new(vacancy).criteria
    @similar_jobs = Search::SimilarJobs.new(vacancy).similar_jobs
    @vacancy = VacancyPresenter.new(vacancy)
  end

  private

  def form
    @form ||= Jobseekers::SearchForm.new(search_params.merge(landing_page: @landing_page))
  end

  def search_params
    return @landing_page.criteria if @landing_page

    strip_empty_checkboxes(%i[job_roles ect_statuses subjects phases quick_apply working_patterns organisation_types school_types]) unless params[:skip_strip_checkboxes]
    %w[job_roles subjects phases working_patterns quick_apply organisation_types].each do |facet|
      params[facet] = params[facet].split if params[facet].is_a?(String)
    end
    params.permit(:keyword, :previous_keyword, :organisation_slug, :location, :radius, :subject, :sort_by,
                  job_roles: [], ect_statuses: [], subjects: [], phases: [], working_patterns: [], quick_apply: [], organisation_types: [], school_types: [])
  end

  def set_landing_page
    if params[:landing_page_slug].present?
      @landing_page = LandingPage[params[:landing_page_slug]]
    elsif params[:organisation_landing_page_name].present?
      @landing_page = OrganisationLandingPage[params[:organisation_landing_page_name]]
    elsif params[:location_landing_page_name].present?
      @landing_page = LocationLandingPage[params[:location_landing_page_name]]
    end
  end

  def set_headers
    response.set_header("X-Robots-Tag", "noarchive")
  end

  def trigger_search_performed_event
    fail_safe do
      vacancy_ids = @vacancies.pluck(:id)
      polygon_id = DfE::Analytics.anonymise(@vacancies_search.location_search.polygon.id) if @vacancies_search.location_search.polygon

      event_data = {
        search_criteria: form.to_hash,
        sort_by: form.sort.by,
        page: params[:page] || 1,
        total_count: @vacancies_search.total_count,
        vacancies_on_page: vacancy_ids,
        location_polygon_used: polygon_id,
        landing_page: params[:landing_page_slug],
        filters_set_from_keywords: form.filters_from_keyword.present?,
      }

      request_event.trigger(:search_performed, event_data)
      trigger_dfe_analytics_event(:search_performed, event_data)
    end
  end

  def trigger_dfe_analytics_event(event_type, event_data)
    event = DfE::Analytics::Event.new
      .with_type(event_type)
      .with_request_details(request)
      .with_response_details(response)
      .with_user(current_jobseeker)
      .with_data(event_data)

    DfE::Analytics::SendEvents.do([event])
  end

  def set_search_coordinates
    return unless form.to_hash[:location]
    @search_coordinates = Geocoding.new(form.to_hash[:location]).coordinates
  end

  def closest_school
  end

  # def distance_to_location
  #   if geolocation.class == RGeo::Geographic::SphericalMultiPointImpl
  #   else
  #     Geocoder::Calculations.distance_between(@search_coordinates, [latitude, longitude]).floor
  #   end
  # end
end
