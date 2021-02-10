class VacanciesController < ApplicationController
  def index
    set_map_display
    params[:location] = params[:location_facet] if params[:location_facet]
    if params.key?(:pretty) && params.key?(params[:pretty])
      @landing_page = params[params[:pretty]]
      @landing_page_translation = "#{params[:pretty]}.#{@landing_page.parameterize.underscore}"
    end
    @jobs_search_form = Jobseekers::SearchForm.new(algolia_search_params)
    @vacancies_search = Search::SearchBuilder.new(@jobs_search_form.to_hash)
    @jobs_search_form.jobs_sort = @vacancies_search.sort_by
    @vacancies = VacanciesPresenter.new(@vacancies_search.vacancies)
  end

  def show
    begin
      vacancy = Vacancy.listed.friendly.find(id)
    rescue ActiveRecord::RecordNotFound
      raise unless Vacancy.trashed.friendly.exists?(id)

      return render "/errors/trashed_vacancy_found", status: :not_found
    end

    return redirect_to(job_path(vacancy), status: :moved_permanently) if old_vacancy_path?(vacancy)

    @saved_job = current_jobseeker&.saved_jobs&.find_by(vacancy_id: vacancy.id)
    @vacancy = VacancyPresenter.new(vacancy)
    @devised_job_alert_search_criteria = Search::CriteriaDeviser.new(vacancy).criteria
    @similar_jobs = Search::SimilarJobs.new(vacancy).similar_jobs

    PersistVacancyPageViewJob.perform_later(vacancy.id) unless publisher_signed_in? || smoke_test?
  end

  private

  def algolia_search_params
    strip_empty_checkboxes(%i[job_roles phases working_patterns])
    %w[job_role job_roles phases working_patterns].each do |facet|
      params[facet] = params[facet].split if params[facet].is_a?(String)
    end
    params.permit(:keyword, :location, :radius, :subject, :buffer_radius, :jobs_sort, :page,
                  job_role: [], job_roles: [], phases: [], working_patterns: [])
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
