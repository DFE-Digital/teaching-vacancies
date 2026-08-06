require "google_indexing"
class UpdateGoogleIndexQueueJob < ApplicationJob
  queue_as :default

  def perform(url)
    return if DisableIntegrations.enabled?

    if (url_indexing = GoogleIndexing.new(url))
      url_indexing.update
    else
      Rails.logger.info("Aborting Google update index. Error: No Google API")
    end
  rescue SystemExit => e
    Rails.logger.info("Aborting Google update index. Error: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Google indexing error: #{e.message}")
    raise
  end
end
