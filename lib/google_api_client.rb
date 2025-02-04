require "googleauth"
require "singleton"

class GoogleApiClient
  include Singleton

  attr_reader :authorizer, :google_api_json_key

  SCOPE = ["https://www.googleapis.com/auth/indexing",
           "https://www.googleapis.com/auth/drive"].freeze

  def initialize
    @google_api_json_key = ENV.fetch("GOOGLE_API_JSON_KEY", "")
    if missing_key?
      Rails.logger.info("***No GOOGLE_API_JSON_KEY set")
      return
    end

    @authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(GOOGLE_API_JSON_KEY),
      scope: SCOPE,
    )
    # Fetch the initial access token
    authorizer.fetch_access_token!
  end

  def authorization
    # Refresh the token if it's expired
    authorizer.fetch_access_token! if authorizer&.expired?
    authorizer
  end

  def missing_key?
    google_api_json_key.empty? || JSON.parse(google_api_json_key).empty?
  end
end
