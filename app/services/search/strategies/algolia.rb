class Search::Strategies::Algolia
  def initialize(search_params)
    @keyword = search_params[:keyword]
    @coordinates = search_params[:coordinates]
    @radius = search_params[:radius]
    @polygons = search_params[:polygons]
    @filters = search_params[:filters]
    @replica = search_params[:replica]
    @per_page = search_params[:per_page]
    @page = search_params[:page]
    @typo_tolerance = search_params[:typo_tolerance]
  end

  def vacancies
    @vacancies ||= Vacancy.includes(:organisations).search(@keyword, search_arguments)
  rescue Algolia::AlgoliaProtocolError => e
    Rollbar.error("Algolia search error", details: e, search_arguments: search_arguments)
    @vacancies = Vacancy.none.page(0).per(0)
  end

  def total_count
    return 0 if vacancies.none?

    vacancies.raw_answer["nbHits"]
  end

  private

  def search_arguments
    {
      aroundLatLng: @coordinates,
      aroundRadius: @radius,
      insidePolygon: @polygons,
      filters: @filters,
      replica: @replica,
      hitsPerPage: @per_page,
      page: @page,
      typoTolerance: @typo_tolerance,
    }.compact
  end
end
