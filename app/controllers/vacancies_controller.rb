class VacanciesController < ApplicationController
  include ParameterSanitiser

  PERMITTED_SEARCH_PARAMS = [phases: [], working_patterns: []]
                            .concat(VacancyFilters::AVAILABLE_FILTERS)
                            .uniq
                            .freeze
  DEFAULT_RADIUS = 20

  helper_method :location,
                :keyword,
                :subject,
                :job_title,
                :working_patterns,
                :phases,
                :specific_phases?,
                :newly_qualified_teacher,
                :radius,
                :sort_column,
                :sort_order
  def index
    redirect_by_jobs_sort && return

    @filters = VacancyFilters.new(search_params.to_hash)

    @sort = VacancySort.new(
      default_column: 'publish_on',
      default_order: 'desc'
    ).update(column: sort_column, order: sort_order)

    @vacancies = VacanciesFinder.new(@filters, @sort, page_number).vacancies
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

  def redirect_by_jobs_sort
    return redirect_with_sort(:expires_on, :asc) if params[:jobs_sort] == 'sort_by_earliest_closing_date'
    return redirect_with_sort(:expires_on, :desc) if params[:jobs_sort] == 'sort_by_furthest_closing_date'
    return redirect_with_sort(:publish_on, :asc) if params[:jobs_sort] == 'sort_by_most_ancient'
    return redirect_with_sort(:publish_on, :desc) if params[:jobs_sort] == 'sort_by_most_recent'
  end

  def redirect_with_sort(sort_column, sort_order)
    redirect_to jobs_path(params: search_params.merge(sort_column: sort_column,
                                                      sort_order: sort_order),
                                                      anchor: 'jobs_sort')
  end

  def search_params
    params.permit(*PERMITTED_SEARCH_PARAMS, :location_category)
          .merge(location: params[:location] || params[:location_category])
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

  def location
    return params[:location_category] if params[:location_category]

    params[:location]
  end

  def keyword
    params[:keyword]
  end

  def subject
    params[:subject]
  end

  def job_title
    params[:job_title]
  end

  def working_patterns_to_a
    raw_working_patterns = params[:working_patterns]
    parsed_working_patterns = JSON.parse(raw_working_patterns) if raw_working_patterns.present?
    parsed_working_patterns.is_a?(Array) ? parsed_working_patterns : []
  rescue JSON::ParserError
    []
  end

  def working_patterns
    working_patterns_to_a
  end

  def phases_to_a
    raw_phases = params[:phases]
    parsed_phases = JSON.parse(raw_phases) if raw_phases.present?
    parsed_phases.is_a?(Array) ? parsed_phases : []
  rescue JSON::ParserError
    []
  end

  def phases
    phases_to_a
  end

  def newly_qualified_teacher
    params[:newly_qualified_teacher]
  end

  def radius
    params[:radius] || DEFAULT_RADIUS
  end

  def sort_column
    params[:sort_column]
  end

  def sort_order
    params[:sort_order]
  end

  def specific_phases?
    return false if phases_to_a.blank?

    phases_to_a.reject(&:blank?).any?
  end

  def set_headers
    response.set_header('X-Robots-Tag', 'noarchive')
  end

  def smoke_test?
    cookies[:smoke_test] != nil
  end

  def valid_search?
    @filters.any? && !smoke_test?
  end

  def audit_row
    { total_count: @vacancies.total_count }.merge(@filters.audit_hash)
  end
end
