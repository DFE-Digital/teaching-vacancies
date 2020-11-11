require "geocoding"

class Search::VacancySearchBuilder
  attr_reader :hits_per_page, :keyword, :location_search,
              :point_coordinates, :search_filters, :search_replica, :sort_by, :stats, :vacancies

  DEFAULT_HITS_PER_PAGE = 10

  def initialize(form_hash)
    @params_hash = form_hash
    @keyword = @params_hash[:keyword]
    @hits_per_page = @params_hash[:per_page] || DEFAULT_HITS_PER_PAGE
    @page = @params_hash[:page]
    initialize_sort_by(@params_hash[:jobs_sort])
    initialize_search
  end

  def call
    @vacancies = search
    @stats = build_stats(
      @vacancies.raw_answer["page"], @vacancies.raw_answer["nbPages"],
      @vacancies.raw_answer["hitsPerPage"], @vacancies.raw_answer["nbHits"]
    )
    @point_coordinates = @location_search.location_filter[:point_coordinates]
    self
  end

  def only_active_to_hash
    @params_hash.delete_if do |k, v|
      v.blank? || (k.eql?(:radius) && @params_hash[:location].blank?) || k.eql?(:jobs_sort) || k.eql?(:page)
    end
  end

  def any?
    filters = only_active_to_hash.dup
    filters.delete_if { |k, _| k.eql?(:radius) }
    filters.any?
  end

  def radius
    location_search.location_filter[:radius]
  end

private

  def initialize_sort_by(jobs_sort_param)
    # A blank `sort_by` results in a search on the main index, Vacancy.
    @sort_by = if jobs_sort_param.blank? || !valid_sort?(jobs_sort_param)
                 @keyword.blank? ? "publish_on_desc" : ""
               else
                 jobs_sort_param
               end
  end

  def initialize_search
    build_location_search
    build_search_filters
    build_search_replica
  end

  def build_location_search
    @location_search = Search::VacancyLocationBuilder.new(
        @params_hash[:location], @params_hash[:radius], @params_hash[:location_category], @params_hash[:user_input_polygon], @params_hash[:user_input_point_coordinates]
    )
    @params_hash[:location_category] = @location_search.location_category if @location_search.location_category_search?
    if @location_search.missing_polygon
      @params_hash[:keyword] = [@keyword, @location_search.location].reject(&:blank?).join(" ")
      @keyword = [@keyword, @location_search.location].reject(&:blank?).join(" ")
    end
  end

  def build_search_filters
    @search_filters = Search::VacancyFiltersBuilder.new(@params_hash).filter_query
  end

  def build_search_replica
    @search_replica = [Indexable::INDEX_NAME, @sort_by].reject(&:blank?).join("_") if @sort_by.present?
  end

  def build_stats(page, pages, results_per_page, total_results)
    return [0, 0, 0] unless total_results.positive?

    first_number = page * results_per_page + 1
    last_number = page + 1 == pages ? total_results : (page + 1) * results_per_page
    [first_number, last_number, total_results]
  end

  def search
    Vacancy.includes(organisation_vacancies: :organisation).search(
        @keyword,
        aroundLatLng: @location_search.location_filter[:point_coordinates],
        aroundRadius: @location_search.location_filter[:radius],
        insidePolygon: @location_search.polygon_coordinates,
        filters: @search_filters,
        replica: @search_replica,
        hitsPerPage: @hits_per_page,
        page: @page,
    )
  end

  def valid_sort?(job_sort_param)
    Vacancy::JOB_SORTING_OPTIONS.map(&:last).include?(job_sort_param)
  end
end
