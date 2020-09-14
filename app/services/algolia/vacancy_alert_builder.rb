class Algolia::VacancyAlertBuilder < Algolia::VacancySearchBuilder
  attr_reader :vacancies

  MAXIMUM_SUBSCRIPTION_RESULTS = 500

  def initialize(subscription_hash)
    @params_hash = subscription_hash
    @keyword = @params_hash[:keyword] || build_subscription_keyword(@params_hash)

    initialize_sort_by(@params_hash[:jobs_sort])
    initialize_search
  end

  def call
    @vacancies = Vacancy.search(
      @keyword,
      aroundLatLng: @location_search.location_filter[:point_coordinates],
      aroundRadius: @location_search.location_filter[:radius],
      insidePolygon: @location_search.location_polygon_boundary,
      filters: @search_filters,
      replica: @search_replica,
      hitsPerPage: MAXIMUM_SUBSCRIPTION_RESULTS,
      typoTolerance: false,
    )
    Rails.logger.info(
      "#{vacancies.count} vacancies found for job alert with criteria: #{@params_hash}, "\
      "search_query: #{@keyword}, replica: #{@search_replica}, location_filter: #{@location_filter} "\
      "and filters: #{@search_filter}",
    )
    @vacancies
  end

private

  def build_subscription_keyword(subscription_hash)
    [subscription_hash[:subject], subscription_hash[:job_title]].reject(&:blank?).join(' ')
  end
end
