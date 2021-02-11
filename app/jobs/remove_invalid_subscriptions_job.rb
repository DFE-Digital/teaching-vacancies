require "remove_invalid_subscriptions"

class RemoveInvalidSubscriptionsJob < ActiveJob::Base
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    RemoveInvalidSubscriptions.new.run!
  end
end
