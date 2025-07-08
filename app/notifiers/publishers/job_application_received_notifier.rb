class Publishers::JobApplicationReceivedNotifier < Noticed::Event
  required_param :vacancy, :job_application

  notification_methods do
    include ActionView::Helpers::UrlHelper
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper
    include DatesHelper

    def message
      t("notifications.publishers/job_application_received_notification.message_html",
        link: application_link, job_title: vacancy.job_title, organisation: vacancy.organisation_name)
    end

    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end

    private

    def application_link
      govuk_link_to "an application", organisation_job_job_application_path(vacancy.id, job_application.id), class: "govuk-link--no-visited-state"
    end

    def job_application
      params[:job_application]
    end

    def vacancy
      params[:vacancy]
    end
  end
end
