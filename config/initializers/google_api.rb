require 'google/apis/indexing_v3'

GOOGLE_API_JSON_KEY = ENV.fetch('GOOGLE_API_JSON_KEY', '')

if GOOGLE_API_JSON_KEY.empty? || JSON.parse(GOOGLE_API_JSON_KEY).empty?
  return Rails.logger.info('***No GOOGLE_API_JSON_KEY set')
end

key = StringIO.new(GOOGLE_API_JSON_KEY)
scope = 'https://www.googleapis.com/auth/indexing'
authorizer = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key,
                                                                scope: scope)
authorizer.fetch_access_token!
Google::Apis::RequestOptions.default.authorization = authorizer
