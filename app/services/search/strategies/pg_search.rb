class Search::Strategies::PgSearch
  attr_reader :keyword, :location, :radius, :page, :per_page, :sort_by

  def initialize(keyword, location:, radius:, page:, per_page:, sort_by:)
    @keyword = keyword

    @location = location
    @radius = radius

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
    scope = scope.order(sort_by.column => sort_by.order) if sort_by&.column
    scope
  end
end
