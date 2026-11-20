require "geocoding"

# Suggests locations for the location autocomplete ("Enter a postcode, town or region"), so that each suggestion is
# something the search resolves without Google (see ADR 0018):
# - the regions, counties and cities we hold a polygon for ("Essex"), searched by area;
# - places in England from the Ordnance Survey Names API, labelled "Name, qualifier" with the qualifier Geocoding needs
#   to pick that same place from Ordnance Survey ("Clapham, London", "Caldecote, South Cambridgeshire");
# - postcodes in England, once the search looks like the start of one ("SW4 0").
class LocationSuggestion
  MINIMUM_LOCATION_INPUT_LENGTH = 3
  NUMBER_OF_SUGGESTIONS = 5
  MAXIMUM_AREA_SUGGESTIONS = 2
  LONDON = "London".freeze
  PLACE_LOCAL_TYPES = (Geocoding::OS_LOCAL_TYPES - %w[Postcode]).freeze
  MINOR_LOCAL_TYPES = %w[village hamlet].freeze
  # An outward code and at least the digit of the inward code.
  PARTIAL_POSTCODE = /\A[A-Z]{1,2}\d[A-Z\d]?\s*\d[A-Z]{0,2}\z/i
  # A place named as an area, or as part of its name (Brighton and "Brighton and Hove"), this close to the area's
  # centre is taken to be the same place, and only the area is suggested.
  SAME_PLACE_KM = 10

  class InsufficientLocationInput < StandardError; end

  class MissingLocationInput < StandardError; end

  attr_reader :location_input

  def initialize(location_input)
    raise MissingLocationInput if location_input.nil?
    raise InsufficientLocationInput if location_input.length < MINIMUM_LOCATION_INPUT_LENGTH

    @location_input = location_input
  end

  # The suggestions, and for each the part matching the search (kept for API compatibility).
  def suggest_locations
    suggestions = if PARTIAL_POSTCODE.match?(location_input.strip)
                    postcode_suggestions
                  else
                    (area_names + place_suggestions.map { |place| place[:label] }).first(NUMBER_OF_SUGGESTIONS)
                  end
    [suggestions, suggestions.map { |suggestion| [suggestion.split(",").first] }]
  end

  def area_names
    @area_names ||= areas.map(&:first)
  end

  # Each place suggestion as { label:, place: }, the place being the Ordnance Survey result it names.
  def place_suggestions
    @place_suggestions ||= candidate_places
      .sort_by { |place| rank(place) }
      .lazy
      .reject { |place| same_as_an_area?(place) }
      .filter_map { |place| labelled(place) }
      .select { |suggestion| continues_typed_qualifier?(suggestion[:label]) }
      .first(NUMBER_OF_SUGGESTIONS)
  end

  private

  def search_name
    location_input.split(",").first.to_s
  end

  def search_key
    normalise(search_name)
  end

  def postcode_suggestions
    search_ordnance_survey(location_input.strip, %w[Postcode])
      .map { |result| result.data["NAME1"] }
      .select { |postcode| normalise(postcode).start_with?(normalise(location_input)) }
      .first(NUMBER_OF_SUGGESTIONS)
  end

  # The Names API matches whole words fuzzily ("Nott" finds Bott End and Nottingham), so only the places whose name,
  # or a later word of a town or suburb ("Leam" finds Royal Leamington Spa), starts with the search are kept.
  def candidate_places
    places.select do |place|
      words = place.data["NAME1"].to_s.split(/[\s-]/)
      starts = MINOR_LOCAL_TYPES.include?(normalise(place.data["LOCAL_TYPE"])) ? [0] : words.each_index
      starts.any? { |index| normalise(words.drop(index).join).start_with?(search_key) }
    end
  end

  # The places Ordnance Survey returns for the search, at most 100: Geocoding chooses among a different set when the
  # suggestion is searched, which `qualifiers` allows for.
  def places
    @places ||= search_ordnance_survey(search_name, PLACE_LOCAL_TYPES)
      .uniq { |place| place.data.values_at("NAME1", "GEOMETRY_X", "GEOMETRY_Y") }
  end

  def places_named(name)
    places.select { |place| normalise(place.data["NAME1"]) == normalise(name) }
  end

  # The results in England for the term, or none if Ordnance Survey can't be reached.
  def search_ordnance_survey(term, local_types)
    return [] if Geocoder.config_for_lookup(:uk_ordnance_survey_names)[:api_key].blank?

    fq = local_types.map { |type| "local_type:#{type}" }.join(" ")
    Geocoder.search(term, lookup: :uk_ordnance_survey_names, params: { fq:, maxresults: 100 })
      .select { |result| result.data["COUNTRY"] == "England" }
  rescue StandardError => e
    # Log the class only: the message can include the request URL, which carries the API key.
    Rails.logger.error("Ordnance Survey Names API location suggestion failed: #{e.class}")
    []
  end

  # Up to two regions, counties and cities with a polygon whose name, or a word in it onwards, starts with the search
  # ("Yorks" finds North Yorkshire), as [display name, polygon].
  def areas
    @areas ||= CITIES_AND_REGIONS.values
      .select { |name| name.exclude?(",") && name_starts_with_search?(name) }
      .sort_by { |name| [normalise(name).start_with?(search_key) ? 0 : 1, name.length] }
      .lazy
      .filter_map { |name| (polygon = LocationPolygon.with_name(name)) && [name, polygon] }
      .first(MAXIMUM_AREA_SUGGESTIONS)
  end

  def name_starts_with_search?(name)
    words = name.split(/[\s-]/)
    words.each_index.any? { |index| normalise(words.drop(index).join).start_with?(search_key) }
  end

  # As Geocoding ranks places (type, then London, then size), then those named exactly as searched, then those whose
  # name starts with the search, then shorter names.
  def rank(place)
    importance, *rest = matcher.prominence(place)
    name = normalise(place.data["NAME1"])
    [importance, name == search_key ? 0 : 1, name.start_with?(search_key) ? 0 : 1, name.length, *rest]
  end

  def matcher
    @matcher ||= Geocoding::OrdnanceSurveyMatcher.new(segments: [], postcode: nil, results: [])
  end

  def same_as_an_area?(place)
    name = normalise(place.data["NAME1"])
    areas.any? do |area_name, polygon|
      normalise(area_name).include?(name) && polygon.centroid &&
        Geocoder::Calculations.distance_between([polygon.centroid.y, polygon.centroid.x], place.coordinates, units: :km) <= SAME_PLACE_KM
    end
  end

  # "Name, qualifier" with the first qualifier for which this place is the only one Geocoding can pick, or nothing if
  # there is none: two hamlets with the same name and district can rank the same, and then the order Ordnance Survey
  # returns them in decides.
  def labelled(place)
    name = place.data["NAME1"]
    qualifiers(place).each do |qualifier|
      return { label: "#{name}, #{qualifier}", place: } if only_choice?(place, [name, qualifier])
    end
    nil
  end

  def only_choice?(place, segments)
    candidates = places_named(place.data["NAME1"]).select do |other|
      Geocoding::OrdnanceSurveyMatcher.new(segments:, postcode: nil, results: [other]).match
    end
    best = candidates.map { |other| matcher.prominence(other) }.min
    candidates.select { |other| matcher.prominence(other) == best } == [place]
  end

  # London places are known as "…, London". Otherwise the district comes before the county: a partial search may not
  # return every place with the name, and the narrower the qualifier, the less likely an unseen one shares it. A
  # qualifier repeating the name ("Ashford, Ashford") is skipped.
  def qualifiers(place)
    data = place.data
    [data["REGION"] == LONDON ? LONDON : nil, data["DISTRICT_BOROUGH"], data["COUNTY_UNITARY"], data["REGION"]]
      .compact.uniq.reject { |qualifier| normalise(qualifier) == normalise(data["NAME1"]) }
  end

  # "Clapham, Lon" keeps the suggestions whose label continues what was typed after the comma.
  def continues_typed_qualifier?(label)
    location_input.exclude?(",") || normalise(label).start_with?(normalise(location_input))
  end

  def normalise(text)
    text.to_s.downcase.gsub(/[^[:alnum:]]/, "")
  end
end
