class Geocoding
  # Chooses the Ordnance Survey Names API result that answers a search, if any. Ordnance Survey answers whenever it
  # has a match in England; Google is only the fallback for when it has none.
  class OrdnanceSurveyMatcher
    # Place types from most to least important, compared with `normalise` as the API may spell them with spaces or
    # underscores. Ordnance Survey uses "Other Settlement" and "Suburban Area" for large places such as Clapham,
    # Hackney or Brixton, so they rank above villages and hamlets. Unknown types rank last.
    LOCAL_TYPE_TIERS = [%w[city], %w[town], %w[suburbanarea othersettlement], %w[village], %w[hamlet]].freeze
    TOWN_LOCAL_TYPES = %w[town city].freeze
    MINOR_LOCAL_TYPES = %w[village hamlet].freeze
    TOWN_TIER = LOCAL_TYPE_TIERS.index(%w[town])
    MINOR_TIER = LOCAL_TYPE_TIERS.index(%w[village])
    LONDON_REGION = "London".freeze

    # How far from the locality in a search such as "Bolton Abbey, Skipton" a place can be.
    LOCALITY_RADIUS_KM = 20

    # `segments` are the comma-separated parts of the search, `postcode` the one that is a postcode, if any.
    def initialize(segments:, postcode:, results:)
      @segments = segments
      @postcode = postcode
      @results = results
    end

    def match
      postcode ? postcode_match : best_place
    end

    def name_matches?
      results.any? { |result| in_england?(result) && name_match?(result) }
    end

    # Google Places describes a place with a nearby locality that Ordnance Survey doesn't record against it ("Bolton
    # Abbey, Skipton"). Among the places with the searched name, whatever the rest of the search says, this is the one
    # closest to that locality, if it is near enough.
    def nearest_to(locality, radius_km: LOCALITY_RADIUS_KM)
      places = results.select { |result| in_england?(result) && name_match?(result) }
      nearest = places.min_by { |result| distance_km(result, locality) }
      nearest if nearest && distance_km(nearest, locality) <= radius_km
    end

    private

    attr_reader :segments, :postcode, :results

    def postcode_match
      results.find do |result|
        result.data["LOCAL_TYPE"] == "Postcode" && in_england?(result) && normalise(result.data["NAME1"]) == normalise(postcode)
      end
    end

    # Of the places in England sharing the searched name, the most important type wins, then London, then the largest:
    # Ordnance Survey has no population, so the size of a place's bounding box stands in for how prominent it is.
    def best_place
      places = exact_places
      places = whole_word_places if places.empty?
      places.min_by { |result| [importance(result), london?(result) ? 0 : 1, -bounding_box_area(result)] }
    end

    # A place in London ranks at least as a town, and wins ties: most searches for an ambiguous name such as Acton or
    # Sutton mean the London one, which is also what Google returns.
    def importance(result)
      tier = local_type_tier(result)
      london?(result) && tier < MINOR_TIER ? [tier, TOWN_TIER].min : tier
    end

    def london?(result)
      result.data["REGION"] == LONDON_REGION
    end

    # For a bare name, towns and cities with a longer name starting with it as a whole word (Newcastle upon Tyne)
    # compete too, unless an exact match is already a town or city.
    def exact_places
      places = results.select { |result| in_england?(result) && same_name?(result) }
      places += longer_named_towns if segments.one? && places.none? { |result| town?(result) }
      places
    end

    # Ordnance Survey sometimes names a place with extra words (Royal Leamington Spa, Kingston upon Hull, Upper
    # Tooting). When nothing is called exactly the first part of the search, in England or elsewhere (Cardiff is not
    # Walton Cardiff), the places with it as whole words are used, except villages and hamlets.
    def whole_word_places
      return [] if results.any? { |result| name_match?(result) }

      whole_word = /(\A|[\s-])#{Regexp.escape(segments.first)}(\z|[\s-])/i
      results.select do |result|
        in_england?(result) && MINOR_LOCAL_TYPES.exclude?(local_type(result)) && whole_word.match?(result.data["NAME1"].to_s)
      end
    end

    def longer_named_towns
      longer_name = /\A#{Regexp.escape(segments.first)}[\s-]/i
      results.select { |result| in_england?(result) && town?(result) && longer_name.match?(result.data["NAME1"].to_s) }
    end

    def same_name?(result)
      name_match?(result) && qualifiers_match?(result)
    end

    def name_match?(result)
      normalise(result.data["NAME1"]) == normalise(segments.first)
    end

    def qualifiers_match?(result)
      location_fields = %w[NAME1 DISTRICT_BOROUGH COUNTY_UNITARY REGION].filter_map { |field| result.data[field] }
      segments.drop(1).all? { |segment| location_fields.any? { |field| normalise(field) == normalise(segment) } }
    end

    def distance_km(place, other)
      Geocoder::Calculations.distance_between(place.coordinates, other.coordinates, units: :km)
    end

    def town?(result)
      TOWN_LOCAL_TYPES.include?(local_type(result))
    end

    def local_type_tier(result)
      LOCAL_TYPE_TIERS.index { |types| types.include?(local_type(result)) } || LOCAL_TYPE_TIERS.size
    end

    def local_type(result)
      normalise(result.data["LOCAL_TYPE"])
    end

    def bounding_box_area(result)
      data = result.data
      (data["MBR_XMAX"].to_f - data["MBR_XMIN"].to_f) * (data["MBR_YMAX"].to_f - data["MBR_YMIN"].to_f)
    end

    def in_england?(result)
      result.data["COUNTRY"] == "England"
    end

    def normalise(text)
      text.to_s.downcase.gsub(/[^[:alnum:]]/, "")
    end
  end
end
