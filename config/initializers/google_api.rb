require 'google/apis/indexing_v3'

GOOGLE_API_JSON_KEY = ENV['GOOGLE_API_JSON_KEY']
return if GOOGLE_API_JSON_KEY.nil?

key = StringIO.new(GOOGLE_API_JSON_KEY)
scope = 'https://www.googleapis.com/auth/indexing'
authorizer = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key,
                                                                scope: scope)
authorizer.fetch_access_token!
Google::Apis::RequestOptions.default.authorization = authorizer
