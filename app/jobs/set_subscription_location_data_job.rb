class SetSubscriptionLocationDataJob < ApplicationJob
  # Uses dbintensive queue as it causes very High DB load when many subscriptions are updated/created at once
  # and we want to limit how many of these jobs run at the same time (see config/sidekiq.yml)
  queue_as :verylow

  # Extracted as a job to avoid slowing down subscription creation
  # by making potentially slow external API calls or database geometry operations.
  def perform(subscription)
    subscription.set_location_data!
  end
end
