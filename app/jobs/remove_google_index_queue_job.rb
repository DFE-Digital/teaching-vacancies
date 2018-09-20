class RemoveGoogleIndexQueueJob < ApplicationJob
  queue_as :default

  def perform(url)
    Indexing.new(url).remove
  rescue StandardError => e
    Rails.logger.error("Sidekiq: Google remove index error: #{e.message}")
    raise
  end
end
