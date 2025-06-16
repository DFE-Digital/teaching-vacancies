class RemoveInvalidSubscriptionsJob < ApplicationJob
  queue_as :low

  def perform
    return if DisableExpensiveJobs.enabled?

    client = GovUkNotifyStatusClient.new
    client.get_email_notifications({ status: "permanent-failure" }).each do |failed_message|
      Subscription.where(email: failed_message.email_address).destroy_all
    end

    Subscription.discarded.find_each.select { |s|
      js = Jobseeker.find_by(email: s.email)
      js.nil? || !js.account_closed?
    }.each(&:destroy!)
  end
end
