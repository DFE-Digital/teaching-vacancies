class VacanciesController < ApplicationController
  before_action :set_landing_page, only: %i[index]

  def index
    @vacancies_search = Search::VacancySearch.new(form.to_hash, sort: form.sort)
    @pagy, @vacancies = pagy(@vacancies_search.vacancies, count: @vacancies_search.total_count)

    set_search_coordinates unless do_not_show_distance?
    trigger_search_performed_event
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

    strip_empty_checkboxes(%i[teaching_job_roles support_job_roles ect_statuses subjects phases quick_apply working_patterns organisation_types school_types visa_sponsorship_availability]) unless params[:skip_strip_checkboxes]
    %w[teaching_job_roles support_job_roles subjects phases working_patterns quick_apply organisation_types].each do |facet|
      params[facet] = params[facet].split if params[facet].is_a?(String)
    end
    params.permit(:keyword, :previous_keyword, :organisation_slug, :location, :radius, :subject, :sort_by, teaching_job_roles: [], support_job_roles: [], ect_statuses: [], subjects: [], phases: [], working_patterns: [], quick_apply: [], organisation_types: [], school_types: [], visa_sponsorship_availability: [])
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
      event_data = {
        data: {
          search_criteria: form.to_hash,
          sort_by: form.sort.by,
          page: params[:page] || 1,
          total_count: @vacancies_search.total_count,
          vacancies_on_page: @vacancies.map(&:id),
          landing_page: params[:landing_page_slug],
          filters_set_from_keywords: form.filters_from_keyword.present?,
        },
        event_hidden_data: {
          location_polygon_used: @vacancies_search&.polygon&.id,
        },
      }

      trigger_dfe_analytics_event(:search_performed, event_data)
    end
  end

  def trigger_dfe_analytics_event(event_type, event_data)
    event = DfE::Analytics::Event.new
      .with_type(event_type)
      .with_request_details(request)
      .with_response_details(response)
      .with_user(current_jobseeker)
      .with_data(data: event_data)

    DfE::Analytics::SendEvents.do([event])
  end

  def set_search_coordinates
    @search_coordinates = Geocoding.new(form.to_hash[:location]).coordinates
  end

  def do_not_show_distance?
    # We don't want to show distance if the user searches for a nationwide location such as "England" or if they search for a location we have a polygon for.
    # This is because the coordinates Google (or other providers) use for London (for example) could be miles away from the location of the school, even if the school is
    # actually in London which could potentially confuse jobseekers.
    normalised_query = form.to_hash[:location]&.strip&.downcase
    normalised_query.nil? || LocationQuery::NATIONWIDE_LOCATIONS.include?(normalised_query) || @vacancies_search.polygon.present?
  end
end
