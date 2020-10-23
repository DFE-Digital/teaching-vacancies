require 'google/cloud/storage'

CLOUD_STORAGE_API_JSON_KEY = ENV['CLOUD_STORAGE_API_JSON_KEY']
GOOGLE_CLOUD_PLATFORM_PROJECT_ID = ENV['GOOGLE_CLOUD_PLATFORM_PROJECT_ID']

if CLOUD_STORAGE_API_JSON_KEY.present?
  Google::Cloud::Storage.configure do |config|
    config.project_id = GOOGLE_CLOUD_PLATFORM_PROJECT_ID
    config.credentials = JSON.parse(CLOUD_STORAGE_API_JSON_KEY)
  end
end
