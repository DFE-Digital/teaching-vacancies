class Publishers::SelfDisclosureReceivedNotifier < ApplicationNotifier
  recipients do
    # find publisher user that has been selected to be the contact for the vacancy
    vacancy = record.self_disclosure_request.job_application.vacancy
    vacancy.organisation.publishers.find_by(email: vacancy.contact_email)
  end

  deliver_by :email do |config|
    config.mailer = "Publishers::CollectReferencesMailer"
    config.method = "self_disclosure_received"
    config.args = :job_application
  end

  notification_methods do
    def message
      t("notifications.publishers/self_disclosure_received_notification.message_html", link: disclosure_link)
    end
    include DatesHelper
    include ActionView::Helpers::UrlHelper
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper

    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end

    private

    def disclosure_link
      govuk_link_to t("notifications.publishers/self_disclosure_received_notification.disclosure_received"),
                    organisation_job_job_application_self_disclosure_path(job_application.vacancy.id, job_application.id),
                    class: "govuk-link--no-visited-state"
    end

    def job_application
      record.self_disclosure_request.job_application
    end
  end

  # this gets passed the notification as a a parameter 'just in case'
  def job_application(*)
    record.self_disclosure_request.job_application
  end
end
