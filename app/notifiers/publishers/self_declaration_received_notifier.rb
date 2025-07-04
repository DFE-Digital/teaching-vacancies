class Publishers::SelfDeclarationReceivedNotifier < ApplicationNotifier
  recipients do
    record.self_disclosure_request.job_application.vacancy.publisher
  end

  deliver_by :email do |config|
    config.mailer = "Publishers::CollectReferencesMailer"
    config.method = "declaration_received"
    config.args = :job_application
  end

  notification_methods do
    def message
      t("notifications.publishers/self_declaration_received_notification.message")
    end
    include DatesHelper

    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end
  end

  # this gets passed the notification as a a parameter 'just in case'
  def job_application(*)
    record.self_disclosure_request.job_application
  end
end
