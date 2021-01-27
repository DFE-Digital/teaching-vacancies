require "indexing"
class RemoveGoogleIndexQueueJob < ApplicationJob
  queue_as :default

  def perform(url)
    Indexing.new(url).remove
  rescue SystemExit => e
    Rails.logger.info("Sidekiq: Aborting Google remove index. Error: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("Sidekiq: Google remove index error: #{e.message}")
    raise
  end
end
