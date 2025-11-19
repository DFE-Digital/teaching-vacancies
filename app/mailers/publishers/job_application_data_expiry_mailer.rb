class Publishers::JobApplicationDataExpiryMailer < Publishers::BaseMailer
  include DatesHelper

  PRIVACY_POLICY_URL = "https://www.gov.uk/government/publications/privacy-information-education-providers-workforce-including-teachers/privacy-information-education-providers-workforce-including-teachers".freeze

  helper_method :data_expiration_date

  def job_application_data_expiry
    publisher = params[:publisher]
    vacancy = params[:vacancy]
    template_mail("4fc32e65-6d2b-4a2a-9b50-29444f55434f",
                  to: publisher.email,
                  personalisation: {
                    job_title: vacancy.job_title,
                    published_date: format_date(vacancy.publish_on, :day_month_year),
                    expiration_date: data_expiration_date(vacancy),
                    published_month: vacancy.publish_on.to_fs(:month_year),
                    privacy_policy_link: PRIVACY_POLICY_URL,
                    view_applications_link: Rails.application.routes.url_helpers.organisation_job_job_applications_url(vacancy.id),
                  })
  end

  private

  def data_expiration_date(vacancy)
    (vacancy.expires_at + 1.year).to_date
  end
end
