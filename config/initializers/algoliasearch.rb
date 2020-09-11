ALGOLIA_PRODUCTION_APP_ID = 'QM2YE0HRBW'.freeze

class AlgoliaEnvironmentError < StandardError
  def initialize
    msg = <<~HERE.chomp
      Do not use the production index #{ALGOLIA_PRODUCTION_APP_ID} in a non-production environment.
      See main README.md for instructions how to create new dev indexes.
    HERE
    super(msg)
  end
end

if !Rails.env.production? && ENV['ALGOLIA_APP_ID'] == ALGOLIA_PRODUCTION_APP_ID
  raise AlgoliaEnvironmentError
end

if ENV['ALGOLIA_APP_ID']
  AlgoliaSearch.configuration = {
    application_id: ENV['ALGOLIA_APP_ID'],
    api_key: ENV['ALGOLIA_WRITE_API_KEY'],
    pagination_backend: :kaminari
  }
end
