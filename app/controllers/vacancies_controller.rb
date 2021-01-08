class VacanciesController < ApplicationController
  include ParameterSanitiser

  def index
    if params.key?(:pretty) && params.key?(params[:pretty])
      @landing_page = params[params[:pretty]]
      @landing_page_translation = "#{params[:pretty]}.#{@landing_page.parameterize.underscore}"
    end
    @jobs_search_form = VacancyAlgoliaSearchForm.new(algolia_search_params)
    @vacancies_search = Search::SearchBuilder.new(@jobs_search_form.to_hash)
    @vacancies = VacanciesPresenter.new(@vacancies_search.vacancies)
    AuditSearchEventJob.perform_later(audit_row) if valid_search?
  end

  def show
    begin
      vacancy = Vacancy.listed.friendly.find(id)
    rescue ActiveRecord::RecordNotFound
      raise unless Vacancy.trashed.friendly.exists?(id)

      return render "/errors/trashed_vacancy_found", status: :not_found
    end

    return redirect_to(job_path(vacancy), status: :moved_permanently) if old_vacancy_path?(vacancy)

    @saved = jobseeker_signed_in? && current_jobseeker.saved_jobs.pluck(:vacancy_id).include?(vacancy.id)
    @vacancy = VacancyPresenter.new(vacancy)
    @devised_job_alert_search_criteria = Search::CriteriaDeviser.new(vacancy).criteria
    @similar_jobs = Search::SimilarJobs.new(vacancy).similar_jobs

    VacancyPageView.new(vacancy).track unless publisher_signed_in? || smoke_test?
  end

  def params
    @params ||= ParameterSanitiser.call(super)
  end

private

  def algolia_search_params
    strip_empty_checkboxes(%i[job_roles phases working_patterns])
    %w[job_role job_roles phases working_patterns].each do |facet|
      params[facet] = params[facet].split if params[facet].is_a?(String)
    end
    params.permit(:keyword, :location, :radius, :location_category, :subject, :buffer_radius, :jobs_sort, :page,
                  job_role: [], job_roles: [], phases: [], working_patterns: [])
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
end
