def application_id
  ENV.fetch('ALGOLIA_APP_ID')
rescue KeyError => e
  Rails.logger.error("Could not find environment variable. Defaulting to 'fake_algolia_app_id'. #{e.message}")
  'fake_algolia_app_id'
end

def api_key
  ENV.fetch('ALGOLIA_WRITE_API_KEY')
rescue KeyError => e
  Rails.logger.error("Could not find environment variable. Defaulting to 'fake_algolia_write_api_key'. #{e.message}")
  'fake_algolia_write_api_key'
end

AlgoliaSearch.configuration = {
  application_id: application_id,
  api_key: api_key
}
