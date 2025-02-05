require "google_indexing"
class RemoveGoogleIndexQueueJob < ApplicationJob
  queue_as :default

  def perform(url)
    if (url_indexing = GoogleIndexing.new(url))
      url_indexing.remove
    else
      Rails.logger.info("Sidekiq: Aborting Google remove index. Error: No Google API")
    end
  rescue SystemExit => e
    Rails.logger.info("Sidekiq: Aborting Google remove index. Error: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Sidekiq: Google remove index error: #{e.message}")
    raise
  end
end
