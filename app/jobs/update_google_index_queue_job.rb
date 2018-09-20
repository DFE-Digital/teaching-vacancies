class UpdateGoogleIndexQueueJob < ApplicationJob
  queue_as :default

  def perform(url)
    Indexing.new(url).update
  rescue StandardError => e
    Rails.logger.error("Sidekiq: Google indexing error: #{e.message}")
    raise
  end
end
