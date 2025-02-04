require "google_indexing"
class UpdateGoogleIndexQueueJob < ApplicationJob
  queue_as :default

  def perform(url)
    if (url_indexing = GoogleIndexing.new(url))
      url_indexing.update
    else
      Rails.logger.info("Sidekiq: Aborting Google remove index. Error: No Google API")
    end
  rescue SystemExit => e
    Rails.logger.info("Sidekiq: Aborting Google update index. Error: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Sidekiq: Google indexing error: #{e.message}")
    raise
  end
end
