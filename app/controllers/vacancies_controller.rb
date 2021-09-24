class VacanciesController < ApplicationController
  helper_method :job_application

  before_action :set_landing_page_description, :set_map_display, only: %i[index]

  def index
    # Set search parameters from pretty landing page params
    search_params

    @vacancies_search = Search::VacancySearch.new(
      search_form.to_hash,
      sort_by: search_form.jobs_sort,
      page: params[:page],
      pg_search: ActiveModel::Type::Boolean.new.cast(params[:pg_search]),
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
    @invented_job_alert_search_criteria = Search::CriteriaInventor.new(vacancy, ab_variant_for(:"2021_10_working_patterns_in_similar_jobs_test")).criteria
    @similar_jobs = Search::SimilarJobs.new(vacancy).similar_jobs
  end

  private

  def search_params
    params[:location] = params[:location_facet].titleize if params[:location_facet]
    params[:job_roles] = params[:job_role].parameterize.underscore if params[:job_role]
    params[:subject]&.titleize
  end

  def algolia_search_params
    strip_empty_checkboxes(%i[job_roles phases working_patterns])
    %w[job_role job_roles phases working_patterns].each do |facet|
      params[facet] = params[facet].split if params[facet].is_a?(String)
    end
    params.permit(:keyword, :location, :radius, :subject, :jobs_sort,
                  job_role: [], job_roles: [], phases: [], working_patterns: [])
  end

  def search_form
    @form = Jobseekers::SearchForm.new(algolia_search_params)
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
end
