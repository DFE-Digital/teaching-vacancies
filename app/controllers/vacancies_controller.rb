class VacanciesController < ApplicationController
  include ParameterSanitiser

  def index
    @jobs_search_form = VacancyAlgoliaSearchForm.new(algolia_search_params)
    @vacancies_search = Search::VacancySearchBuilder.new(@jobs_search_form.to_hash)
    @vacancies_search.call
    @vacancies = VacanciesPresenter.new(@vacancies_search.vacancies)
    @polygon = polygon if @vacancies_search.location_search.location_polygon_boundary.present?
    AuditSearchEventJob.perform_later(audit_row) if valid_search?
    expires_in 5.minutes, public: true
  end

  def show
    begin
      vacancy = Vacancy.listed.friendly.find(id)
    rescue ActiveRecord::RecordNotFound
      raise unless Vacancy.trashed.friendly.exists?(id)

      return render "/errors/trashed_vacancy_found", status: :not_found
    end

    return redirect_to(job_path(vacancy), status: :moved_permanently) if old_vacancy_path?(vacancy)

    @vacancy = VacancyPresenter.new(vacancy)
    @devised_job_alert_search_criteria = Search::CriteriaDeviser.new(vacancy).criteria
    @similar_jobs = Search::VacancySimilarJobs.new(vacancy).similar_jobs

    VacancyPageView.new(vacancy).track unless authenticated? || smoke_test?

    expires_in 5.minutes, public: true
  end

  def params
    @params ||= ParameterSanitiser.call(super)
  end

private

  def algolia_search_params
    strip_empty_checkboxes(%i[job_roles phases working_patterns])
    %w[job_roles phases working_patterns].each do |facet|
      params[facet] = params[facet].split(" ") if params[facet].is_a?(String)
    end
    params.permit(:keyword, :location, :location_category, :radius, :jobs_sort, :page,
                  job_roles: [], phases: [], working_patterns: [])
  end

  def old_vacancy_path?(vacancy)
    request.path != job_path(vacancy) && !request.format.json?
  end

  def id
    params[:id]
  end

  def page_number
    return Vacancy.page.total_pages if Vacancy.page(params[:page]).out_of_range?

    params[:page]
  end

  def set_headers
    response.set_header("X-Robots-Tag", "noarchive")
  end

  def valid_search?
    @vacancies_search.any? && !smoke_test?
  end

  def smoke_test?
    cookies[:smoke_test] != nil
  end

  def audit_row
    @jobs_search_form.to_hash.merge(total_count: @vacancies_search.vacancies.raw_answer["nbHits"])
  end

  def polygon
    max_number_of_points = 20
    polygon = @vacancies_search.location_search.location_polygon_boundary.first
        .each_slice(2).to_a.map { |element| {lat: element.first, lng: element.second} }
    number_of_points = polygon.length
    if number_of_points > max_number_of_points
      polygon = polygon.values_at *(0..(number_of_points-1)).step(number_of_points/max_number_of_points)
    end
    polygon.to_json
  end
end
