module Publishers
  class JobApplicationDataExpiryMailer < BaseMailer
    include DatesHelper

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
                      view_applications_link: organisation_job_job_applications_url(vacancy.id),
                      home_page_link: root_url,
                    })
    end

    private

    def data_expiration_date(vacancy)
      (vacancy.expires_at + 1.year).to_date
    end
  end
end
