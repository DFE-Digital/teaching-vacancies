class Publishers::ReferenceReceivedNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "Publishers::CollectReferencesMailer"
    config.method = "reference_received"
    config.args = :reference_request
  end

  required_param :reference_request

  notification_methods do
    def message
      t("notifications.publishers/reference_received_notification.message")
    end
    include DatesHelper

    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end
  end

  def reference_request(_ignored)
    params.fetch(:reference_request)
  end
end
