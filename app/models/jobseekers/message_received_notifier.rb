module Jobseekers
  class MessageReceivedNotifier < ApplicationNotifier
    recipients do
      record.conversation.job_application.jobseeker
    end

    deliver_by :email do |config|
      config.mailer = "Jobseekers::MessageMailer"
      config.method = :message_received
      config.args = :message
    end

    # rubocop:disable Metrics/BlockLength
    notification_methods do
      def message
        if unsuccessful_application?
          t("notifications.jobseekers/message_received_notification.unsuccessful.message_html",
            link: message_link,
            job_title: job_title,
            school_name: school_name)
        else
          t("notifications.jobseekers/message_received_notification.default.message_html",
            link: message_link,
            job_title: job_title)
        end
      end

      include DatesHelper
      include ActionView::Helpers::UrlHelper
      include GovukVisuallyHiddenHelper
      include GovukLinkHelper

      def timestamp
        "#{day(created_at)} at #{format_time(created_at)}"
      end

      private

      def message_link
        govuk_link_to "a message", jobseekers_job_application_path(job_application, tab: "messages"), class: "govuk-link--no-visited-state"
      end

      def unsuccessful_application?
        job_application.status == "unsuccessful"
      end

      def job_application
        record.conversation.job_application
      end

      def job_title
        job_application.vacancy.job_title
      end

      def school_name
        job_application.vacancy.organisation.name
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
