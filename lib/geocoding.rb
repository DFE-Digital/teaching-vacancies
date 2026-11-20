require "geocoding/ordnance_survey_matcher"

class Geocoding
  # The geographical coordinates of the UK are stable and unlikely to change, allowing us to cache the results for an
  # extended period.
  # Ordnance Survey lookups are free, so the cache mainly saves latency. It still avoids repeat Google calls for
  # locations Ordnance Survey cannot match (see ADR 0017).
  CACHE_DURATION = 180.days

  # The Ordnance Survey LOCAL_TYPE values we search. The geocoder gem's own filter omits Suburban_Area, which Ordnance
  # Survey uses for places such as the London districts.
  OS_LOCAL_TYPES = %w[City Town Suburban_Area Village Other_Settlement Hamlet Postcode].freeze

  # Trailing parts such as the ", UK" that Google Places autocomplete suggestions, still held by job alerts, end with.
  COUNTRY_SUFFIXES = ["uk", "united kingdom", "england", "gb", "great britain"].freeze
  UK_POSTCODE = /\A[A-Z]{1,2}\d[A-Z\d]?\s*\d[A-Z]{2}\z/i

  ACCEPTED_UK_CENTROID_LOCATIONS = ["united kingdom", "uk", "gb", "great britain", "britain"].freeze
  COORDINATES_UK_CENTROID = [55.378051, -3.435973].freeze
  COORDINATES_NO_MATCH = [0, 0].freeze

  attr_reader :location

  def initialize(location)
    @location = location
  end

  def coordinates
    os_results = []
    Rails.cache.fetch([:geocoding, location], expires_in: CACHE_DURATION, skip_nil: true) do
      os_results = ordnance_survey_results
      os_coordinates(os_results) || google_coordinates
    end || no_coordinates_match
  rescue Geocoder::OverQueryLimitError
    # Last resort, deliberately not cached: the weak match must not outlive the Google quota problem.
    os_results.find { |result| result.data["COUNTRY"] == "England" }&.coordinates || no_coordinates_match
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

  def postcode_from_coordinates # rubocop:disable Metrics/AbcSize
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

  # The search location split on commas, without trailing country parts ("Clapham, London, UK" => Clapham, London).
  def segments
    @segments ||= begin
      parts = location.to_s.split(",").map(&:strip).compact_blank
      parts.pop while parts.size > 1 && COUNTRY_SUFFIXES.include?(parts.last.downcase.delete("."))
      parts
    end
  end

  def postcode_segment
    segments.find { |segment| UK_POSTCODE.match?(segment) }
  end

  # Ordnance Survey is asked for one term only: the postcode if there is one, otherwise the first part of the search.
  def ordnance_survey_results
    search_ordnance_survey(postcode_segment || segments.first)
  end

  def search_ordnance_survey(term)
    return [] if term.blank? || Geocoder.config_for_lookup(:uk_ordnance_survey_names)[:api_key].blank?

    Geocoder.search(term, lookup: :uk_ordnance_survey_names, params: { fq: OS_LOCAL_TYPES.map { |type| "local_type:#{type}" }.join(" ") })
  rescue StandardError => e
    # Log the class only: the message can include the request URL, which carries the API key.
    Rails.logger.error("Ordnance Survey Names API lookup failed: #{e.class}")
    []
  end

  # Ordnance Survey answers whenever it has a match in England: Google is only the fallback for when it has none.
  def os_coordinates(results)
    return if segments.empty?

    matcher = OrdnanceSurveyMatcher.new(segments:, postcode: postcode_segment, results:)
    (matcher.match || place_near_locality(matcher))&.coordinates
  end

  # "Bolton Abbey, Skipton": older Google Places suggestions name a nearby locality that Ordnance Survey doesn't record
  # for the place, so look the locality up too and use the place with that name that is closest to it.
  def place_near_locality(matcher)
    return if segments.one? || postcode_segment || !matcher.name_matches?

    locality = OrdnanceSurveyMatcher.new(segments: [segments.second], postcode: nil, results: search_ordnance_survey(segments.second)).exact_match
    matcher.nearest_to(locality) if locality
  end

  # 'components: "country:gb"' is used to restrict the results to within the UK.
  # When searching for a location outside the UK, the Google Geocoding API returns the UK centroid coordinates.
  def google_coordinates
    Geocoder.coordinates(location, lookup: :google, components: "country:gb").tap do |coords|
      trigger_google_geocoding_api_hit_event(type: :coordinates, location:, result: coords)
    end
  rescue Geocoder::OverQueryLimitError
    trigger_google_geocoding_api_hit_event(type: :coordinates, location:, result: "OVER_QUERY_LIMIT")
    Rails.logger.error("Google Geocoding API responded with OVER_QUERY_LIMIT")
    raise
  end

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
