class DeleteJobseekersWithIncorrectEmailsJob < ApplicationJob
  queue_as :low

  def perform
    client = GovUkNotifyStatusClient.new
    responses = client.get_email_notifications(status: "permanent-failure")

    failed_email_addresses = responses.map(&:email_address)

    Jobseeker.where(email: failed_email_addresses, confirmed_at: nil).destroy_all
  end
end
