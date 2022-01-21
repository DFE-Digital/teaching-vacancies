class VacanciesController < ApplicationController
  helper_method :allow_sorting?, :job_application

  before_action :set_landing_page_description, :set_map_display, :set_params_from_pretty_landing_page_params, only: %i[index]
  after_action :trigger_search_performed_event, only: %i[index]

  def index
    @vacancies_search = Search::VacancySearch.new(
      search_form.to_hash,
      sort: search_form.sort,
      page: params[:page],
    )
    @vacancies = VacanciesPresenter.new(@vacancies_search.vacancies)
  end

  def show
    begin
      vacancy = Vacancy.listed.friendly.find(id)
    rescue ActiveRecord::RecordNotFound
      @vacancy = Vacancy.trashed.friendly.find(id)

      return render "/errors/trashed_vacancy_found", status: :not_found
    end

    return redirect_to(job_path(vacancy), status: :moved_permanently) if old_vacancy_path?(vacancy)

    @saved_job = current_jobseeker&.saved_jobs&.find_by(vacancy_id: vacancy.id)
    @vacancy = VacancyPresenter.new(vacancy)
    @invented_job_alert_search_criteria = Search::CriteriaInventor.new(vacancy).criteria
    @similar_jobs = Search::SimilarJobs.new(vacancy).similar_jobs
  end

  private

  def set_params_from_pretty_landing_page_params
    params[:location] = params[:location_facet].titleize if params[:location_facet]
    params[:job_roles] = params[:job_role].parameterize.underscore if params[:job_role]
    params[:phases] = params[:education_phase].parameterize if params[:education_phase]
    params[:subject] = params[:subject].tr("-", " ").gsub(" and ", " ") if params[:subject]
  end

  def search_params
    strip_empty_checkboxes(%i[job_roles phases working_patterns])
    %w[job_role job_roles phases working_patterns].each do |facet|
      params[facet] = params[facet].split if params[facet].is_a?(String)
    end
    params.permit(:keyword, :location, :radius, :subject, :sort_by,
                  job_role: [], job_roles: [], phases: [], working_patterns: [])
  end

  def search_form
    @form = Jobseekers::SearchForm.new(search_params)
  end

  def job_application
    @job_application ||= current_jobseeker&.job_applications&.find_by(vacancy_id: vacancy.id)
  end

  def vacancy
    @vacancy ||= Vacancy.listed.friendly.find(id)
  end

  def old_vacancy_path?(vacancy)
    request.path != job_path(vacancy) && !request.format.json?
  end

  def id
    params[:id]
  end

  def allow_sorting?
    @vacancies_search.sort.many? && @vacancies.many?
  end

  def set_headers
    response.set_header("X-Robots-Tag", "noarchive")
  end

  def set_landing_page_description
    return unless params.key?(:pretty) && params.key?(params[:pretty])

    @landing_page = params[params[:pretty]]
    @landing_page_translation = "#{params[:pretty]}.#{@landing_page.parameterize.underscore}"
  end

  def set_map_display
    @display_map = params[:location]&.include?("+map")

    params[:location]&.gsub!("+map", "")
  end

  def trigger_search_performed_event
    fail_safe do
      vacancy_ids = @vacancies_search.vacancies.map(&:id).map { |s| StringAnonymiser.new(s).to_s }
      polygon_id = StringAnonymiser.new(@vacancies_search.location_search.polygon.id).to_s if @vacancies_search.location_search.polygon

      request_event.trigger(
        :search_performed,
        search_criteria: search_form.to_hash,
        sort_by: search_form.sort.by,
        page: params[:page] || 1,
        total_count: @vacancies_search.total_count,
        vacancies_on_page: vacancy_ids,
        location_polygon_used: polygon_id,
      )
    end
  end
end
