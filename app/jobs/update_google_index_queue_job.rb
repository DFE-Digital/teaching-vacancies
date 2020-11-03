require "indexing"
class UpdateGoogleIndexQueueJob < ApplicationJob
  queue_as :google_indexing

  def perform(url)
    Indexing.new(url).update
  rescue SystemExit => e
    Rails.logger.info("Sidekiq: Aborting Google update index. Error: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Sidekiq: Google indexing error: #{e.message}")
    raise
  end
end
