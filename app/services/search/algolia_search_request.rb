class Search::AlgoliaSearchRequest
  attr_reader :vacancies, :total_count

  def initialize(search_params)
    @keyword = search_params[:keyword]
    @coordinates = search_params[:coordinates]
    @radius = search_params[:radius]
    @polygons = search_params[:polygons]
    @filters = search_params[:filters]
    @replica = search_params[:replica]
    @hits_per_page = search_params[:hits_per_page]
    @page = search_params[:page]
    @typo_tolerance = search_params[:typo_tolerance]

    @vacancies = search
    return if @vacancies.nil?

    @total_count = vacancies.raw_answer["nbHits"]
  end

  private

  def search
    Vacancy.includes(organisation_vacancies: :organisation).search(@keyword, search_arguments)
  rescue Algolia::AlgoliaProtocolError => e
    Rollbar.error("Algolia search error", details: e, search_arguments: search_arguments)
    nil
  end

  def search_arguments
    {
      aroundLatLng: @coordinates,
      aroundRadius: @radius,
      insidePolygon: @polygons,
      filters: @filters,
      replica: @replica,
      hitsPerPage: @hits_per_page,
      page: @page,
      typoTolerance: @typo_tolerance,
    }.compact
  end
end
