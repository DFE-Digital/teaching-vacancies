module Jobseekers
  class MessageReceivedNotifier < ApplicationNotifier
    recipients do
      record.conversation.job_application.jobseeker
    end

    deliver_by :email do |config|
      config.mailer = "Jobseekers::MessageMailer"
      # called in the scope of the notification via instance_exec
      # This has to check the 'failed' concept as it is run later, and the job_application has already been marked as
      # rejected before this code has run
      config.method = proc { record.conversation.job_application.application_failed? ? :rejection_message : :message_received }
      config.args = :message_instance
    end

    # rubocop:disable Metrics/BlockLength
    notification_methods do
      def message
        if job_application.unsuccessful?
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

    def message_instance(*)
      record
    end
  end
  # rubocop:enable Metrics/BlockLength
end
