class Search::AlgoliaSearchRequest
  attr_reader :vacancies, :stats

  def initialize(search_params)
    @keyword = search_params[:keyword]
    @coordinates = search_params[:coordinates]
    @radius = search_params[:radius]
    @polygon = search_params[:polygon]
    @filters = search_params[:filters]
    @replica = search_params[:replica]
    @hits_per_page = search_params[:hits_per_page]
    @page = search_params[:page]
    @typo_tolerance = search_params[:typo_tolerance]

    @vacancies = search
    return if @vacancies.nil?

    @stats = build_stats(
      vacancies.raw_answer["page"],
      vacancies.raw_answer["nbPages"],
      vacancies.raw_answer["hitsPerPage"],
      vacancies.raw_answer["nbHits"],
    )
  end

private

  def build_stats(page, pages, results_per_page, total_results)
    return [0, 0, 0] unless total_results.positive?

    first_number = page * results_per_page + 1
    last_number = page + 1 == pages ? total_results : (page + 1) * results_per_page
    [first_number, last_number, total_results]
  end

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
      insidePolygon: @polygon,
      filters: @filters,
      replica: @replica,
      hitsPerPage: @hits_per_page,
      page: @page,
      typoTolerance: @typo_tolerance,
    }.compact
  end
end
