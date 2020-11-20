require "remove_invalid_subscriptions"

class RemoveInvalidSubscriptionsJob < ApplicationJob
  queue_as :remove_invalid_subscriptions

  def perform
    return if DisableExpensiveJobs.enabled?

    RemoveInvalidSubscriptions.new.run!
  end
end
