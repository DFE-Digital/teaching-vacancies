class Search::VacancySearch
  DEFAULT_HITS_PER_PAGE = 20
  DEFAULT_PAGE = 1

  extend Forwardable
  def_delegators :location_search, :point_coordinates

  attr_reader :search_criteria, :keyword, :location, :radius, :sort_by, :page, :per_page

  def initialize(search_criteria, sort_by: nil, page: nil, per_page: nil)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @location = search_criteria[:location]
    @radius = search_criteria[:radius]

    @sort_by = sort_by || Search::VacancySearchSort::RELEVANCE
    @per_page = (per_page || DEFAULT_HITS_PER_PAGE).to_i
    @page = (page || DEFAULT_PAGE).to_i
  end

  def active_criteria
    search_criteria
      .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
  end

  def active_criteria?
    active_criteria.any?
  end

  def location_search
    @location_search ||= Search::LocationBuilder.new(search_criteria[:location], search_criteria[:radius])
  end

  def search_filters
    @search_filters ||= Search::FiltersBuilder.new(search_criteria).filter_query
  end

  def wider_search_suggestions
    return unless vacancies.empty? && search_criteria[:location].present?

    Search::WiderSuggestionsBuilder.new(search_criteria).suggestions
  end

  def out_of_bounds?
    page_from > total_count
  end

  def page_from
    ((page - 1) * per_page) + 1
  end

  def page_to
    [(page * per_page), total_count].min
  end

  def vacancies
    @vacancies ||= scope.page(page).per(per_page)
  end

  def total_count
    vacancies.total_count
  end

  private

  def scope
    scope = Vacancy.live
    scope = scope.search_by_location(location, radius) if location
    scope = scope.search_by_filter(search_criteria) if search_criteria.any?
    scope = scope.search_by_full_text(keyword) if keyword.present?
    scope = scope.reorder(sort_by.column => sort_by.order) if sort_by&.column

    # Adds an additional order by updated at for searches so a non-deterministic order column
    # (e.g. date instead of datetime) will still result in the same order as Algolia for
    # comparison. Can probably be removed post-migration.
    scope.order(updated_at: :desc)
  end
end
