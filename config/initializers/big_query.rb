require "google/cloud/bigquery"

BIG_QUERY_API_JSON_KEY = ENV['BIG_QUERY_API_JSON_KEY']

Google::Cloud::Bigquery.configure do |config|
  config.project_id  = "teacher-vacancy-service"
  config.credentials = JSON.parse(BIG_QUERY_API_JSON_KEY)
end

bigquery = Google::Cloud::Bigquery.new