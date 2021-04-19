class Publishers::JobApplicationReceivedNotification < Noticed::Base
  include ActionView::Helpers::UrlHelper
  include GovukLinkHelper

  deliver_by :database
  delegate :created_at, to: :record
  param :vacancy, :job_application

  def message
    t("notifications.publishers/job_application_received_notification.message_html",
      link: application_link, job_title: vacancy.job_title, organisation: vacancy.parent_organisation_name)
  end

  def timestamp
    return created_at.strftime("Today at %H:%I") if created_at.today?
    return created_at.strftime("Yesterday at %H:%I") if created_at.yesterday?

    created_at.strftime("%B %d at %H:%I")
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
