class Search::Strategies::PgSearch
  attr_reader :keyword, :location, :radius, :filters, :page, :per_page, :sort_by

  def initialize(keyword, location:, radius:, filters:, page:, per_page:, sort_by:)
    @keyword = keyword

    @location = location
    @radius = radius
    @filters = filters

    @page = page
    @per_page = per_page
    @sort_by = sort_by
  end

  def vacancies
    @vacancies ||= scope.page(page).per(per_page)
  end

  def total_count
    vacancies.total_count
  end

  private

  def scope
    # This strategy can currently only search by location (not keywords yet) so this avoids
    # polluting our metrics for now
    return Vacancy.none if keyword.present?

    scope = Vacancy.live
    scope = scope.search_by_location(location, radius) if location
    scope = scope.search_by_filter(filters) if filters.any?
    scope = scope.order(sort_by.column => sort_by.order) if sort_by&.column

    # Adds an additional order by updated at for searches so a non-deterministic order column
    # (e.g. date instead of datetime) will still result in the same order as Algolia for
    # comparison. Can probably be removed post-migration.
    scope.order(updated_at: :desc)
  end
end
