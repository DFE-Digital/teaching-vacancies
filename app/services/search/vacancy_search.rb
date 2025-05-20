class Search::VacancySearch
  extend Forwardable
  def_delegators :location_search, :point_coordinates, :polygon

  attr_reader :search_criteria, :keyword, :location, :radius, :organisation_slug, :sort, :original_scope

  def initialize(search_criteria, sort: nil, scope: Vacancy.live)
    @search_criteria = search_criteria
    @keyword = search_criteria[:keyword]
    @location = search_criteria[:location]
    @radius = search_criteria[:radius]
    @organisation_slug = search_criteria[:organisation_slug]
    @sort = sort || Search::VacancySort.new(keyword: keyword, location: location)
    @original_scope = scope.kept.where(scope.where_values_hash)
    @scope = scope.kept
  end

  def active_criteria
    search_criteria
      .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
  end

  def clear_filters_params
    active_criteria.merge(teaching_job_roles: [], support_job_roles: [], ect_statuses: [], phases: [], working_patterns: [], quick_apply: [], subjects: [], organisation_types: [], school_types: [], previous_keyword: keyword, visa_sponsorship_availability: [], skip_strip_checkboxes: true)
  end

  def remove_filter_params
    active_criteria.merge(previous_keyword: keyword)
  end

  def active_criteria?
    active_criteria.any?
  end

  def location_search
    @location_search ||= Search::LocationBuilder.new(search_criteria[:location], search_criteria[:radius])
  end

  def wider_search_suggestions
    @wider_search_suggestions ||= Search::WiderSuggestionsBuilder.call(self)
  end

  def organisation
    @organisation ||= Organisation.find_by(slug: organisation_slug) if organisation_slug
  end

  def vacancies
    @vacancies ||= scope
  end

  def total_count
    @total_count ||= vacancies.size
  end

  private

  def scope
    sort_by_distance = sort.by == "distance"
    scope = @scope.includes(:organisations)
    scope = scope.where(id: organisation.all_vacancies.pluck(:id)) if organisation
    scope = scope.search_by_location(location, radius, polygon:, sort_by_distance:) if location
    scope = scope.search_by_filter(search_criteria) if search_criteria.any?
    scope = scope.search_by_full_text(keyword) if keyword.present?
    order_scope(scope, sort_by_distance)
  end

  def sort_by
    if sort.by == "publish_on_non_default"
      "publish_on"
    else
      sort.by
    end
  end

  def order_scope(scope, sort_by_distance)
    # if sort_by_distance is true then the sorting is handled by the search_by_filter method so we do not re-order here.
    return scope if sort_by_distance
    # only re-order the query if sort is a valid db column
    return scope unless sort&.by_db_column?

    scope.reorder(sort_by => sort.order)
  end
end
