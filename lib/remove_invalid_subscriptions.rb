require "notifications/client"

class RemoveInvalidSubscriptions
  # The GOV.UK Notify API retrieves a maximum of 250 messages that are 7 days old or newer

  def run!
    permanent_failures.each do |failed_message|
      Subscription.where(email: failed_message.email_address).destroy_all
    end
  end

  private

  def api_response
    Notifications::Client.new(NOTIFY_KEY).get_notifications(args)
  end

  def args
    { template_type: "email", status: "failed" }
  end

  def permanent_failures
    api_response.collection.select { |response| response.status == "permanent-failure" }
  end
end
