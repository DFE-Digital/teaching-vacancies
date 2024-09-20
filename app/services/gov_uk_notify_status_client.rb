class GovUkNotifyStatusClient
  def initialize
    @client = Notifications::Client.new(ENV.fetch("NOTIFY_KEY", nil))
  end

  def get_email_notifications(options = {})
    opts = options.merge(template_type: "email")
    notifications = @client.get_notifications(opts).collection

    Enumerator.new do |yielder|
      while notifications.any?
        notifications.each { |n| yielder << n }

        notifications = @client.get_notifications(opts.merge(older_than: notifications.last.id)).collection
      end
    end
  end
end
