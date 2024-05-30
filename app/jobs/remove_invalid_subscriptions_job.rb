class RemoveInvalidSubscriptionsJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    Jobseekers::RemoveInvalidSubscriptions.new.call
  end
end
