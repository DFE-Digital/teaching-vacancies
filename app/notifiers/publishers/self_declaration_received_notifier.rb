class Publishers::SelfDeclarationReceivedNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "Publishers::CollectReferencesMailer"
    config.method = "declaration_received"
    config.args = :job_application
  end

  required_param :job_application

  notification_methods do
    def message
      t("notifications.publishers/self_declaration_received_notification.message")
    end
    include DatesHelper

    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end
  end

  def job_application(_ignored)
    params.fetch(:job_application)
  end
end
