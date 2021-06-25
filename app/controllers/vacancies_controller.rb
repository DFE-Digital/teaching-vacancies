class VacanciesController < ApplicationController
  helper_method :job_application

  attr_accessor :canonical_href

  SEO_CANONICAL_TEST_VACANCIES = %w[c9f9a45f-1f42-4686-9515-311bc169af29 ef21f5d2-4226-4cf8-b8d2-3155e149b0b2].freeze

  def index
    set_map_display
    params[:location] = params[:location_facet] if params[:location_facet]
    if params.key?(:pretty) && params.key?(params[:pretty])
      @landing_page = params[params[:pretty]]
      @landing_page_translation = "#{params[:pretty]}.#{@landing_page.parameterize.underscore}"
    end
    @jobs_search_form = Jobseekers::SearchForm.new(algolia_search_params)
    @vacancies_search = Search::VacancySearch.new(@jobs_search_form.to_hash, sort_by: @jobs_search_form.jobs_sort, page: params[:page])
    @vacancies = VacanciesPresenter.new(@vacancies_search.vacancies)
  end

  def show
    begin
      vacancy = Vacancy.listed.friendly.find(id)
    rescue ActiveRecord::RecordNotFound
      @vacancy = Vacancy.trashed.friendly.find(id)

      return render "/errors/trashed_vacancy_found", status: :not_found
    end

    canonical

    return redirect_to(job_path(vacancy), status: :moved_permanently) if old_vacancy_path?(vacancy)

    @saved_job = current_jobseeker&.saved_jobs&.find_by(vacancy_id: vacancy.id)
    @vacancy = VacancyPresenter.new(vacancy)
    @devised_job_alert_search_criteria = Search::CriteriaDeviser.new(vacancy).criteria
    @similar_jobs = Search::SimilarJobs.new(vacancy).similar_jobs

    PersistVacancyPageViewJob.perform_later(vacancy.id) unless publisher_signed_in? || smoke_test?
  end

  private

  UUID_REGEX = /\b[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\b/

  def canonical
    return unless SEO_CANONICAL_TEST_VACANCIES.include?(vacancy.id)

    return unless UUID_REGEX.match(id) || !job_path(vacancy).end_with?(vacancy.slug)

    @canonical_href = job_url(id)
  end

  def algolia_search_params
    strip_empty_checkboxes(%i[job_roles phases working_patterns])
    %w[job_role job_roles phases working_patterns].each do |facet|
      params[facet] = params[facet].split if params[facet].is_a?(String)
    end
    params.permit(:keyword, :location, :radius, :subject, :buffer_radius, :jobs_sort,
                  job_role: [], job_roles: [], phases: [], working_patterns: [])
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

  def valid_search?
    @vacancies_search.active_criteria? && !smoke_test?
  end

  def smoke_test?
    cookies[:smoke_test] != nil
  end

  def set_map_display
    @display_map = params[:location]&.include?("+map")

    params[:location]&.gsub!("+map", "")
  end
end
