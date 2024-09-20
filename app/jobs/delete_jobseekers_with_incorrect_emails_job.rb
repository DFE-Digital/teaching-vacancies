class DeleteJobseekersWithIncorrectEmailsJob < ApplicationJob
  queue_as :low

  def perform
    client = GovUkNotifyStatusClient.new
    # This isn't particularily well-documented, but this picks up
    # all failures temporary-failure, permanent-failure and technical-failure
    responses = client.get_email_notifications(status: "failure")

    failed_email_addresses = responses.map(&:email_address)

    Jobseeker.where(email: failed_email_addresses, confirmed_at: nil).destroy_all
  end
end
