require "google_indexing"
class UpdateGoogleIndexQueueJob < ApplicationJob
  queue_as :default

  def perform(url)
    GoogleIndexing.new(url).update
  rescue SystemExit => e
    Rails.logger.info("Sidekiq: Aborting Google update index. Error: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Sidekiq: Google indexing error: #{e.message}")
    raise
  end
end
