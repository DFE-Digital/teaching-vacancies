class DeleteJobseekersWithIncorrectEmailsJob < ApplicationJob
  queue_as :low

  def perform
    client = Notifications::Client.new(ENV.fetch("NOTIFY_KEY"))

    failed_email_addresses = client.get_notifications(template_type: "email", status: "permanent-failure").collection.map(&:email_address)

    Jobseeker.where(email: failed_email_addresses, confirmed_at: nil).destroy_all
  end
end
