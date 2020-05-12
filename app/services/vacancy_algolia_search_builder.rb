require 'geocoding'

class VacancyAlgoliaSearchBuilder
  include ActiveModel::Model

  attr_accessor :keyword, :location_category, :location, :radius, :sort_by, :page, :hits_per_page,
                :search_query, :location_filter, :search_replica, :search_filter,
                :vacancies

  DEFAULT_RADIUS = 10
  DEFAULT_HITS_PER_PAGE = 10

  def initialize(params)
    self.keyword = params[:keyword]

    self.location_filter = {}
    self.search_filter = "publication_date_timestamp <= #{date_today_filter} AND "\
                         "expires_at_timestamp > #{date_today_filter}"

    self.sort_by = params[:jobs_sort] if valid_sort?(params[:jobs_sort])
    self.hits_per_page = params[:per_page] || DEFAULT_HITS_PER_PAGE
    self.page = params[:page]

    initialize_location(params[:location_category], params[:location], params[:radius])
    initialize_search
  end

  def call
    self.vacancies = Vacancy.search(
      search_query,
      aroundLatLng: location_filter[:coordinates],
      aroundRadius: location_filter[:radius],
      replica: search_replica,
      hitsPerPage: hits_per_page,
      filters: search_filter,
      page: page
    )
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
    @location_category_search ||= (location_category && LocationCategory.include?(location_category))
  end

  def only_active_to_hash
    to_hash.delete_if { |_, v| v.blank? }
  end

  def any?
    filters = only_active_to_hash
    filters.delete_if { |k, _| k.eql?(:radius) }
    filters.any?
  end

  def convert_radius_in_miles_to_metres(radius)
    (radius * 1.60934 * 1000).to_i
  end

  private

  def initialize_search
    build_search_query
    build_location_filter if location_category.blank?
    build_search_replica
  end

  def initialize_location(location_category, location, radius)
    self.location = location
    self.radius = (radius || DEFAULT_RADIUS).to_i
    self.location_category = (location.present? && LocationCategory.include?(location)) ?
      location : location_category
  end

  def build_search_query
    self.search_query = [keyword, location_category].reject(&:blank?).join(' ')
  end

  def build_location_filter
    self.location_filter[:coordinates] = Geocoding.new(location).coordinates if location.present?
    self.location_filter[:radius] = convert_radius_in_miles_to_metres(radius) if location.present?
  end

  def build_search_replica
    return nil if sort_by.blank?
    self.search_replica = ['Vacancy', Rails.env.test? ? 'test' : '', sort_by].reject(&:blank?).join('_')
  end

  def date_today_filter
    Time.zone.today.to_datetime.to_i
  end

  def valid_sort?(job_sort_param)
    Vacancy::JOB_SORTING_OPTIONS.map { |sort_option| sort_option.last }.include? job_sort_param
  end
end
