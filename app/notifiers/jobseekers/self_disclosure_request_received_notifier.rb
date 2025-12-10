module Jobseekers
  class SelfDisclosureRequestReceivedNotifier < ApplicationNotifier
    recipients do
      record.job_application.jobseeker
    end

    deliver_by :email do |config|
      config.mailer = "Jobseekers::JobApplicationMailer"
      config.method = :self_disclosure
      config.args = :job_application
    end

    notification_methods do
      def message
        t("notifications.jobseekers/self_disclosure_request_received_notification.message_html",
          link: disclosure_link, job_title: job_application.vacancy.job_title,
          school_name: job_application.vacancy.organisation.name)
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
        govuk_link_to t("notifications.jobseekers/self_disclosure_request_received_notification.disclosure_received"),
                      jobseekers_job_application_self_disclosure_path(job_application, Wicked::FIRST_STEP),
                      class: "govuk-link--no-visited-state"
      end

      def job_application
        record.job_application
      end
    end

    # this gets passed the notification as a a parameter 'just in case'
    def job_application(*)
      record.job_application
    end
  end
end
