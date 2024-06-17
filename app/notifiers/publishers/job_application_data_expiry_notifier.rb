class Publishers::JobApplicationDataExpiryNotifier < Noticed::Event

  deliver_by :database
  deliver_by :email, mailer: "Publishers::JobApplicationDataExpiryMailer", method: :job_application_data_expiry
  delegate :created_at, to: :record
  param :vacancy, :publisher

  notification_methods do
    include ActionView::Helpers::UrlHelper
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper
    include DatesHelper
    
    def message
      t("notifications.publishers/job_application_data_expiry_notification.message_html",
        link: vacancy_applications_link, date: format_date(data_expiration_date))
    end
  
    def timestamp
      "#{day(created_at)} at #{format_time(created_at)}"
    end

    private
  
    def data_expiration_date
      (vacancy.expires_at + 1.year).to_date
    end
  
    def vacancy
      params[:vacancy]
    end
  
    def vacancy_applications_link
      govuk_link_to vacancy.job_title, organisation_job_job_applications_path(vacancy.id), class: "govuk-link--no-visited-state"
    end
  end
end
