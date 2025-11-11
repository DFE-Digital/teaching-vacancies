class SetSubscriptionLocationDataJob < ApplicationJob
  queue_as :default

  # Extracted as a job to avoid slowing down subscription creation
  # by making potentially slow external API calls or database geometry operations.
  def perform(subscription)
    subscription.set_location_data!
  end
end
