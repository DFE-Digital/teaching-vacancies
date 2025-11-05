class Publishers::ReferenceReceivedNotifier < ApplicationNotifier
  recipients do
    # find publisher user that has been selected to be the contact for the vacancy
    vacancy = record.reference_request.referee.job_application.vacancy
    vacancy.organisation.publishers.find_by(email: vacancy.contact_email)
  end

  deliver_by :email do |config|
    config.mailer = "Publishers::CollectReferencesMailer"
    config.method = "reference_received"
    config.args = :reference_request
  end

  notification_methods do
    def message
      t("notifications.publishers/reference_received_notification.message_html", link: reference_link)
    end

    include DatesHelper
    include ActionView::Helpers::UrlHelper
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper

    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end

    private

    def reference_link
      govuk_link_to t("notifications.publishers/reference_received_notification.reference_received"),
                    organisation_job_job_application_reference_request_path(job_application.vacancy.id, job_application.id, event.record.reference_request),
                    class: "govuk-link--no-visited-state"
    end

    def job_application
      record.reference_request.referee.job_application
    end
  end

  # this gets passed the notification as a a parameter 'just in case'
  def reference_request(*)
    record.reference_request
  end
end
