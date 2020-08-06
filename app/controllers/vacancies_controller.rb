class VacanciesController < ApplicationController
  include ParameterSanitiser

  def index
    @jobs_search_form = VacancyAlgoliaSearchForm.new(algolia_search_params)
    @vacancies_search = VacancyAlgoliaSearchBuilder.new(algolia_search_params)
    @vacancies_search.call
    @vacancies = VacanciesPresenter.new(
      @vacancies_search.vacancies,
      searched: @vacancies_search.any?,
      total_count: @vacancies_search.vacancies.raw_answer['nbHits'],
      coordinates: @vacancies_search.coordinates
    )
    AuditSearchEventJob.perform_later(audit_row) if valid_search?
    expires_in 5.minutes, public: true
  end

  def show
    begin
      vacancy = Vacancy.listed.friendly.find(id)
    rescue ActiveRecord::RecordNotFound
      raise unless Vacancy.trashed.friendly.exists?(id)

      return render '/errors/trashed_vacancy_found', status: :not_found
    end

    return redirect_to(job_path(vacancy), status: :moved_permanently) if old_vacancy_path?(vacancy)

    @vacancy = VacancyPresenter.new(vacancy)

    VacancyPageView.new(vacancy).track unless authenticated? || smoke_test?

    expires_in 5.minutes, public: true
  end

  def params
    @params ||= ParameterSanitiser.call(super)
  end

  private

  def algolia_search_params
    (params[:jobs_search_form] || params)
      .permit(:keyword, :location, :location_category, :radius, :jobs_sort, :page)
      .merge(params.permit(:page, :jobs_sort))
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
    response.set_header('X-Robots-Tag', 'noarchive')
  end

  def valid_search?
    @vacancies_search.any? && !smoke_test?
  end

  def smoke_test?
    cookies[:smoke_test] != nil
  end

  def audit_row
    @vacancies_search.to_hash.merge(total_count: @vacancies_search.vacancies.raw_answer['nbHits'])
  end
end
