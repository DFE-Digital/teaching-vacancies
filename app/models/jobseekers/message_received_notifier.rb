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

    notification_methods do
      def message_text
        if unsuccessful_application?
          t("notifications.jobseekers/message_received_notification.unsuccessful.message_html", 
            job_title: job_title,
            school_name: school_name)
        else
          t("notifications.jobseekers/message_received_notification.default.message_html", 
            job_title: job_title)
        end
      end

      include DatesHelper
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper

      def timestamp
        "#{day(created_at)} at #{format_time(created_at)}"
      end

      private

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

    def message(*)
      record
    end
  end
end