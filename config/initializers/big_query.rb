require "google/cloud/bigquery"

if (api_key = ENV.fetch("BIG_QUERY_API_JSON_KEY", nil)).present?
  Google::Cloud::Bigquery.configure do |config|
    config.project_id  = "teacher-vacancy-service"
    config.credentials = JSON.parse(api_key)
  end
end
