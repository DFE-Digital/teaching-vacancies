class Geocoding
  # The geographical coordinates of the UK are stable and unlikely to change, allowing us to cache the results for an
  # extended period.
  # Due to the high volume of location searches we receive daily (over 70k/day at the time of writing),
  # the cache refresh period significantly impacts our Google Geocoding API usage and billing.
  CACHE_DURATION = 180.days

  ACCEPTED_UK_CENTROID_LOCATIONS = ["united kingdom", "uk", "gb", "great britain", "britain"].freeze
  COORDINATES_UK_CENTROID = [55.378051, -3.435973].freeze
  COORDINATES_NO_MATCH = [0, 0].freeze

  attr_reader :location

  def initialize(location)
    @location = location
  end

  # 9th November 2026. This hand-rolled cache code is slowly being removed as we have enabled
  # the library-level cache facility. Over the next few months, the library cache will match our manual cache,
  # at which point the manual cache code can be removed safely
  # The cache has significant costs involved in its setup, so cannot be trivially replaced
  # Once the library cache is being populated, it could be slowly replaced by a database implementation
  # inclding the idea of a database implementation fallback
  # (read from redis/fallback to DB, write to DB)

  def coordinates
    Rails.cache.fetch([:geocoding, location], expires_in: CACHE_DURATION, skip_nil: true) do
      # 'components: "country:gb"' is used to restrict the results to within the UK.
      # When searching for a location outside the UK, the Google Geocoding API returns the UK centroid coordinates.
      Geocoder.coordinates(location, lookup: :google, components: "country:gb").tap do |coords|
        trigger_google_geocoding_api_hit_event(type: :coordinates, location:, result: coords)
      end
    rescue Geocoder::OverQueryLimitError
      trigger_google_geocoding_api_hit_event(type: :coordinates, location:, result: "OVER_QUERY_LIMIT")
      Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
      Geocoder.coordinates(location, lookup: :uk_ordnance_survey_names)
    end || no_coordinates_match
  end

  # Why not use: 'Geocoder.search(value).map(&:country).include?("United Kingdom")'?
  #
  # This would always trigger a new API call to Geocoder, which is not ideal.
  # We are already caching all the search location coordinates to avoid unnecessary API calls and costs.
  # We want to avoid triggering API calls when possible and reduce costs.
  #
  # The search call also marks some legitimate UK location terms (suggested by Google Place Autocomplete) as outside the UK.
  # We prefer to have a more relaxed check rather than to reject valid UK locations.
  def uk_coordinates?
    coordinates = self.coordinates
    return false if coordinates.blank? || coordinates == Geocoding::COORDINATES_NO_MATCH

    if coordinates == Geocoding::COORDINATES_UK_CENTROID
      # Google Geocode API returns the UK centroid coordinates when the search options restrict the results to within the UK
      # and the location is outside the UK.
      # Checks if the location is one of the UK locations that should return the centroid coordinates
      location.strip.downcase.delete(".").in?(ACCEPTED_UK_CENTROID_LOCATIONS)
    else
      true # Coordinates are valid and not the UK centroid, so it's in the UK.
    end
  end

  private

  def trigger_google_geocoding_api_hit_event(type:, location:, result:)
    event = DfE::Analytics::Event.new
      .with_type(:google_geocoding_api_hit)
      .with_data(data: { type:, location: location.to_s, result: result&.to_s })

    DfE::Analytics::SendEvents.do([event])
  end

  def no_coordinates_match
    Rails.logger.info("The Geocoder API returned no coordinates match (0, 0) for '#{location}'. This was not cached.")
    COORDINATES_NO_MATCH
  end
end
