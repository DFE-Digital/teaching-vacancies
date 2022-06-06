class VacanciesController < ApplicationController
  MAX_TOTAL_RESULTS_FOR_MAP = 500

  before_action :set_landing_page, only: %i[index]
  after_action :trigger_search_performed_event, only: %i[index]

  def index
    @vacancies_search = Search::VacancySearch.new(
      form.to_hash,
      sort: form.sort,
      page: params[:page],
    )
    @vacancies = @vacancies_search.vacancies

    @show_map = current_variant?(:"2022_05_show_map_results", :show_map) &&
                @vacancies_search.location &&
                @vacancies_search.total_count <= MAX_TOTAL_RESULTS_FOR_MAP
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

    strip_empty_checkboxes(%i[job_roles subjects phases working_patterns])
    %w[job_role job_roles subjects phases working_patterns].each do |facet|
      params[facet] = params[facet].split if params[facet].is_a?(String)
    end
    params.permit(:keyword, :previous_keyword, :location, :radius, :subject, :sort_by,
                  job_role: [], job_roles: [], subjects: [], phases: [], working_patterns: [])
  end

  def set_landing_page
    if params[:landing_page_slug].present?
      @landing_page = LandingPage[params[:landing_page_slug]]
    elsif params[:location_landing_page_name].present?
      @landing_page = LocationLandingPage[params[:location_landing_page_name]]
    end
  end

  def set_headers
    response.set_header("X-Robots-Tag", "noarchive")
  end

  def trigger_search_performed_event
    fail_safe do
      vacancy_ids = @vacancies_search.vacancies.map(&:id).map { |s| StringAnonymiser.new(s).to_s }
      polygon_id = StringAnonymiser.new(@vacancies_search.location_search.polygon.id).to_s if @vacancies_search.location_search.polygon

      request_event.trigger(
        :search_performed,
        search_criteria: form.to_hash,
        sort_by: form.sort.by,
        page: params[:page] || 1,
        total_count: @vacancies_search.total_count,
        vacancies_on_page: vacancy_ids,
        location_polygon_used: polygon_id,
        landing_page: params[:landing_page_slug],
        filters_set_from_keywords: form.filters_from_keyword.present?,
      )
    end
  end
end
