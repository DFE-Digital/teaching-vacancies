class DeleteJobseekersWithIncorrectEmails < ApplicationJob
  queue_as :default

  def perform
    client = Notifications::Client.new(ENV.fetch("NOTIFY_KEY"))

    failed_email_addresses = client.get_notifications(template_type: "email", status: "permanent-failure").collection.map(&:email_address)

    failed_email_addresses.each do |failed_email|
      Jobseeker.find_by(email: failed_email)&.destroy
    end
  end
end
