class Publishers::MessageReceivedNotifier < Noticed::Event
  recipients do
    record.conversation.job_application.publisher
  end

  # rubocop:disable Metrics/BlockLength
  notification_methods do
    include ActionView::Helpers::UrlHelper
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper
    include DatesHelper

    def message
      t("notifications.publishers/message_received_notification.message_html",
        link: message_link,
        job_title: job_title,
        candidate_name: candidate_name)
    end

    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end

    private

    def message_link
      govuk_link_to "a message", messages_organisation_job_job_application_path(
        job_application.vacancy.id,
        job_application.id,
      ), class: "govuk-link--no-visited-state"
    end

    def job_application
      record.conversation.job_application
    end

    def job_title
      job_application.vacancy.job_title
    end

    def candidate_name
      job_application.name
    end
  end
  # rubocop:enable Metrics/BlockLength
end
