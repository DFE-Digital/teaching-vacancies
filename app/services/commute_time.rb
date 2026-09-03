class CommuteTime
  ENDPOINT = "https://routes.googleapis.com/directions/v2:computeRoutes".freeze
  POSTCODE_PATTERN = /\A(?:GIR ?0AA|[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2})\z/i
  TRAVEL_MODES = {
    "driving" => "DRIVE",
    "walking" => "WALK",
    "transit" => "TRANSIT",
  }.freeze

  class InvalidPostcodeError < StandardError; end
  class InvalidTravelModeError < StandardError; end
  class RouteNotFoundError < StandardError; end
  class RequestError < StandardError; end

  def self.valid_postcode?(postcode)
    postcode.to_s.strip.match?(POSTCODE_PATTERN)
  end

  def self.valid_travel_mode?(travel_mode)
    TRAVEL_MODES.key?(travel_mode.to_s)
  end

  def initialize(postcode:, destination:, travel_mode:)
    @postcode = postcode.to_s.strip.upcase
    @destination = destination
    @travel_mode = travel_mode.to_s
  end

  def duration_in_minutes
    validate!

    (route_duration.delete_suffix("s").to_f / 60).ceil
  end

  private

  attr_reader :postcode, :destination, :travel_mode

  def validate!
    raise InvalidPostcodeError unless self.class.valid_postcode?(postcode)
    raise InvalidTravelModeError unless self.class.valid_travel_mode?(travel_mode)
    raise RouteNotFoundError unless destination.is_a?(RGeo::Feature::Point)
    raise RequestError if GOOGLE_ROUTES_API_KEY.blank?
  end

  def route_duration
    response = connection.post do |request|
      request.headers["Content-Type"] = "application/json"
      request.headers["X-Goog-Api-Key"] = GOOGLE_ROUTES_API_KEY
      request.headers["X-Goog-FieldMask"] = "routes.duration"
      request.body = request_body.to_json
    end

    raise_request_error!(response) unless response.success?

    duration = JSON.parse(response.body).dig("routes", 0, "duration")
    raise RouteNotFoundError if duration.blank?

    duration
  rescue JSON::ParserError, Faraday::Error => e
    raise RequestError, e.message
  end

  def raise_request_error!(response)
    message = JSON.parse(response.body).dig("error", "message")
    raise RequestError, "Google Routes API returned #{response.status}: #{message}"
  rescue JSON::ParserError
    raise RequestError, "Google Routes API returned #{response.status}"
  end

  def connection
    HttpClient.connection(
      url: ENDPOINT,
      retry_options: { methods: %i[post] },
    )
  end

  def request_body
    {
      origin: { address: "#{postcode}, United Kingdom" },
      destination: {
        location: {
          latLng: {
            latitude: destination.y,
            longitude: destination.x,
          },
        },
      },
      travelMode: TRAVEL_MODES.fetch(travel_mode),
    }
  end
end
