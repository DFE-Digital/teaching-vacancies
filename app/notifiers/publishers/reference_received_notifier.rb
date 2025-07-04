class Publishers::ReferenceReceivedNotifier < ApplicationNotifier
  recipients do
    record.referee.job_application.vacancy.publisher
  end

  deliver_by :email do |config|
    config.mailer = "Publishers::CollectReferencesMailer"
    config.method = "reference_received"
    config.args = :reference_request
  end

  notification_methods do
    def message
      t("notifications.publishers/reference_received_notification.message")
    end
    include DatesHelper

    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end
  end

  # this gets passed the notification as a a parameter 'just in case'
  def reference_request(*)
    record.referee.reference_request
  end
end
