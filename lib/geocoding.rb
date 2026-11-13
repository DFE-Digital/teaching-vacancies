class Geocoding
  # Coordinates are stored in the geocoded_locations table (see GeocodedLocation) rather than in Rails.cache:
  # the cache is short-lived and evicts entries oldest-first, while the volume of location searches we receive
  # daily (over 70k/day at the time of writing) makes every avoided Google Geocoding API call a cost saving.

  ACCEPTED_UK_CENTROID_LOCATIONS = ["united kingdom", "uk", "gb", "great britain", "britain"].freeze
  COORDINATES_UK_CENTROID = [55.378051, -3.435973].freeze
  COORDINATES_NO_MATCH = [0, 0].freeze

  attr_reader :location

  def initialize(location)
    @location = location
  end

  def coordinates
    return no_coordinates_match if lookup_key.blank?

    stored = GeocodedLocation.find_by(query: lookup_key)
    return stored_coordinates(stored) if stored&.fresh?

    coords, confirmed_no_match = legacy_cached_coordinates || fetch_coordinates
    if coords
      GeocodedLocation.store!(lookup_key, coords)
      coords
    else
      GeocodedLocation.store!(lookup_key, nil) if confirmed_no_match
      stored&.coordinates || no_coordinates_match # a stale row is better than no answer when the APIs fail
    end
  end

  # Why not use: 'Geocoder.search(value).map(&:country).include?("United Kingdom")'?
  #
  # This would always trigger a new API call to Geocoder, which is not ideal.
  # We are already storing all the search location coordinates to avoid unnecessary API calls and costs.
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

  def lookup_key
    @lookup_key ||= GeocodedLocation.normalise(location)
  end

  def stored_coordinates(stored)
    stored.no_match? ? no_coordinates_match : stored.coordinates
  end

  # TODO: remove once the Rails cache no longer holds geocoding entries from before GeocodedLocation existed.
  def legacy_cached_coordinates
    cached = Rails.cache.read([:geocoding, location])
    [cached, false] if cached
  end

  # Returns the coordinates, and whether Google positively reported no result (as opposed to failing).
  def fetch_coordinates
    # 'components: "country:gb"' is used to restrict the results to within the UK.
    # When searching for a location outside the UK, the Google Geocoding API returns the UK centroid coordinates.
    coords = Geocoder.coordinates(location, lookup: :google, components: "country:gb")
    trigger_google_geocoding_api_hit_event(type: :coordinates, location:, result: coords)
    [coords, coords.nil?]
  rescue Geocoder::OverQueryLimitError
    trigger_google_geocoding_api_hit_event(type: :coordinates, location:, result: "OVER_QUERY_LIMIT")
    Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
    [Geocoder.coordinates(location, lookup: :uk_ordnance_survey_names), false]
  end

  def no_coordinates_match
    Rails.logger.info("The Geocoder API returned no coordinates match (0, 0) for '#{location}'.")
    COORDINATES_NO_MATCH
  end
end
