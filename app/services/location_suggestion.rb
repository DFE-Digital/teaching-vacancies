class LocationSuggestion
  MINIMUM_LOCATION_INPUT_LENGTH = 3
  NUMBER_OF_SUGGESTIONS = 5

  class InsufficientLocationInput < StandardError; end

  class MissingLocationInput < StandardError; end

  class GooglePlacesAutocompleteError < StandardError; end

  attr_accessor :location_input

  def initialize(location_input)
    raise MissingLocationInput if location_input.nil?
    raise InsufficientLocationInput if location_input.length < MINIMUM_LOCATION_INPUT_LENGTH

    self.location_input = location_input
  end

  def suggest_locations
    predictions = get_suggestions_from_google["predictions"].take(NUMBER_OF_SUGGESTIONS)
    suggestions = predictions.map { |prediction| prediction["description"] }
    matched_terms = predictions.map do |prediction|
      prediction["terms"].select { |term| term["offset"].zero? }.map { |hit| hit["value"] }
    end
    [suggestions, matched_terms]
  end

private

  def request_url
    "https://maps.googleapis.com/maps/api/place/autocomplete/json?#{build_google_query.to_query}"
  end

  def get_suggestions_from_google
    response = HTTParty.get(request_url)
    raise HTTParty::ResponseError, "Something went wrong" unless response.success?

    parsed_response = JSON.parse(response.body)
    raise GooglePlacesAutocompleteError, parsed_response["error_message"] if
      parsed_response.key?("error_message")

    parsed_response
  end

  def build_google_query
    {
      key: GOOGLE_PLACES_AUTOCOMPLETE_KEY,
      language: "en",
      input: location_input,
      components: "country:uk",
      type: "geocode",
      region: "uk",
    }
  end
end
