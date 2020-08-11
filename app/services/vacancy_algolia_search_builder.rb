require 'geocoding'

class VacancyAlgoliaSearchBuilder
  include ActiveModel::Model

  attr_accessor :keyword, :location_category, :location, :radius, :sort_by, :page, :hits_per_page, :stats,
                :location_filter, :location_polygon, :point_coordinates, :search_replica, :search_filter,
                :vacancies

  DEFAULT_RADIUS = 10
  DEFAULT_HITS_PER_PAGE = 10

  def initialize(params)
    self.keyword = params[:keyword]

    self.location_filter = {}
    # Although we are no longer indexing expired and pending vacancies, we need to maintain this filter for now as
    # expired vacancies only get removed from the index once a day.
    self.search_filter = 'listing_status:published AND '\
                         "publication_date_timestamp <= #{published_today_filter} AND "\
                         "expires_at_timestamp > #{expired_now_filter}"

    self.hits_per_page = params[:per_page] || DEFAULT_HITS_PER_PAGE
    self.page = params[:page]

    initialize_sort_by(params[:jobs_sort])
    initialize_location(params)
    initialize_search
  end

  def call
    self.vacancies = search
    self.stats = build_stats(
      vacancies.raw_answer['page'], vacancies.raw_answer['nbPages'],
      vacancies.raw_answer['hitsPerPage'], vacancies.raw_answer['nbHits']
    )
    self.point_coordinates = location_filter[:point_coordinates]
  end

  def to_hash
    {
      keyword: keyword,
      location_category: location_category,
      location: location,
      radius: radius,
      jobs_sort: sort_by
    }
  end

  def location_category_search?
    (location_category && LocationCategory.include?(location_category)) ||
    (location && LocationCategory.include?(location))
  end

  def disable_radius?
    location_category_search? || location.blank?
  end

  def only_active_to_hash
    to_hash.delete_if { |k, v| v.blank? || (k.eql?(:radius) && to_hash[:location].blank?) }
  end

  def any?
    filters = only_active_to_hash
    filters.delete_if { |k, _| k.eql?(:radius) || k.eql?(:jobs_sort) }
    filters.any?
  end

  def convert_radius_in_miles_to_metres(radius)
    (radius * 1.60934 * 1000).to_i
  end

  def build_stats(page, pages, results_per_page, total_results)
    return [0, 0, 0] unless total_results > 0
    first_number = page * results_per_page + 1
    if page + 1 === pages
      last_number = total_results
    else
      last_number = (page + 1) * results_per_page
    end
    [first_number, last_number, total_results]
  end

  private

  def initialize_search
    build_location_filter if location_category.blank?
    build_search_replica
  end

  def search
    Vacancy.search(
      keyword,
      aroundLatLng: location_filter[:point_coordinates],
      aroundRadius: location_filter[:radius],
      insidePolygon: location_polygon_boundary,
      replica: search_replica,
      hitsPerPage: hits_per_page,
      filters: search_filter,
      page: page
    )
  end

  def location_polygon_boundary
    location_polygon.present? ? [location_polygon.boundary] : nil
  end

  def initialize_location(initialization_hash)
    self.location = initialization_hash[:location] || initialization_hash[:location_category]
    self.radius = (initialization_hash[:radius] || DEFAULT_RADIUS).to_i
    self.location_category = (location.present? && LocationCategory.include?(location)) ?
      location : initialization_hash[:location_category]
    initialize_location_polygon if location_category_search?
  end

  def initialize_location_polygon
    self.location_polygon = LocationPolygon.find_by(name: location_category.downcase)
    if location_polygon.nil? &&
      (DOWNCASE_REGIONS + DOWNCASE_COUNTIES).include?(location_category.downcase)
      # If a location category that we expect to have a polygon actually does not,
      # append the location category to the text search as a fallback.
      # This applies only to regions and counties: large areas for which there is
      # very little value in using a point coordinate, and for which there is a
      # low chance of ambiguity (unlike Clapham borough vs Clapham village in Bedfordshire)
      Rollbar.log(:error,
        "A location category search was performed as a text search as no LocationPolygon could
        be found with the name '#{location_category.downcase}'.")
      self.keyword = [keyword, location_category].reject(&:blank?).join(' ')
    end
  end

  def initialize_sort_by(jobs_sort_param)
    # A blank `sort_by` results in a search on the main index, Vacancy.
    if jobs_sort_param.blank? || !valid_sort?(jobs_sort_param)
      self.sort_by = keyword.blank? ? 'publish_on_desc' : ''
    else
      self.sort_by = jobs_sort_param
    end
  end

  def build_location_filter
    self.location_filter[:point_coordinates] = Geocoding.new(location).coordinates if location.present?
    self.location_filter[:radius] = convert_radius_in_miles_to_metres(radius) if location.present?
  end

  def build_search_replica
    return nil if sort_by.blank?
    self.search_replica = ['Vacancy', sort_by].reject(&:blank?).join('_')
  end

  def published_today_filter
    Time.zone.today.to_datetime.to_i
  end

  def expired_now_filter
    Time.zone.now.to_datetime.to_i
  end

  def valid_sort?(job_sort_param)
    Vacancy::JOB_SORTING_OPTIONS.map { |sort_option| sort_option.last }.include? job_sort_param
  end
end
