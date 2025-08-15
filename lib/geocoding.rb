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

  def postcode_from_coordinates
    Rails.cache.fetch([:postcode_from_coords, location], expires_in: CACHE_DURATION, skip_nil: true) do
      result = Geocoder.search(location, lookup: :google).first
      if result.present?
        postcode = result.data["address_components"].find { |line| "postal_code".in?(line["types"]) }&.dig("short_name")
        trigger_google_geocoding_api_hit_event(type: :postcode, location:, result: postcode)
        postcode
      else
        trigger_google_geocoding_api_hit_event(type: :postcode, location:, result: nil)
        nil
      end
    rescue Geocoder::OverQueryLimitError
      trigger_google_geocoding_api_hit_event(type: :postcode, location:, result: "OVER_QUERY_LIMIT")
      Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
      fallback_postcode_from_coords
    end || no_postcode_match
  end

  private

  def trigger_google_geocoding_api_hit_event(type:, location:, result:)
    event = DfE::Analytics::Event.new
      .with_type(:google_geocoding_api_hit)
      .with_data(data: { type:, location: location.to_s, result: result&.to_s })

    DfE::Analytics::SendEvents.do([event])
  end

  def fallback_postcode_from_coords(service: :nominatim)
    result = Geocoder.search(location, lookup: service).first.data
    if result["error"].present?
      Rails.logger.error("Geocoding Nominatim API responded with error: #{result['error']}")
      no_postcode_match
    else
      result["address"]["postcode"]
    end
  end

  def no_coordinates_match
    Rails.logger.info("The Geocoder API returned no coordinates match (0, 0) for '#{location}'. This was not cached.")
    COORDINATES_NO_MATCH
  end

  def no_postcode_match
    Rails.logger.info("The Geocoder API returned no postcode match for '#{location}'. This was not cached.")
    nil
  end
end
