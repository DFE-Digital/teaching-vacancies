require 'google/apis/indexing_v3'

GOOGLE_API_JSON_KEY = ENV.fetch('GOOGLE_API_JSON_KEY', '')
GOOGLE_ANALYTICS_PROFILE_ID = ENV.fetch('GOOGLE_ANALYTICS_PROFILE_ID', '')

if GOOGLE_API_JSON_KEY.empty? || JSON.parse(GOOGLE_API_JSON_KEY).empty?
  return Rails.logger.info('***No GOOGLE_API_JSON_KEY set')
end

scope = ['https://www.googleapis.com/auth/indexing',
         'https://www.googleapis.com/auth/analytics',
         'https://www.googleapis.com/auth/drive']

key = StringIO.new(GOOGLE_API_JSON_KEY)
authorizer = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key,
                                                                scope: scope)
authorizer.fetch_access_token!
Google::Apis::RequestOptions.default.authorization = authorizer
