class Search::AlertBuilder < Search::SearchBuilder
  attr_reader :vacancies

  MAXIMUM_SUBSCRIPTION_RESULTS = 500

  def initialize(subscription_hash)
    @params_hash = subscription_hash
    @keyword = @params_hash[:keyword] || build_subscription_keyword(@params_hash)

    call_search
  end

  private

  def build_subscription_keyword(subscription_hash)
    [subscription_hash[:subject], subscription_hash[:job_title]].reject(&:blank?).join(" ")
  end

  def search_params
    {
      keyword: keyword,
      coordinates: location_search.location_filter[:point_coordinates],
      radius: location_search.location_filter[:radius],
      polygons: location_search.polygon_boundaries,
      filters: search_filters,
      replica: search_replica,
      hits_per_page: MAXIMUM_SUBSCRIPTION_RESULTS,
      typo_tolerance: false,
    }.compact
  end
end
