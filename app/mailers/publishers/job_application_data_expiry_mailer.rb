class Publishers::JobApplicationDataExpiryMailer < Publishers::BaseMailer
  include DatesHelper

  helper_method :data_expiration_date

  def job_application_data_expiry
    @template = template
    @publisher = params[:publisher]
    @vacancy = params[:vacancy]
    @to = @publisher.email
    @subject = I18n.t("publishers.job_application_data_expiry_mailer.job_application_data_expiry.subject", job_title: @vacancy.job_title, published_date: format_date(@vacancy.publish_on, :day_month_year))

    view_mail(@template, to: @to, subject: @subject)
  end

  private

  def data_expiration_date
    (@vacancy.expires_at + 1.year).to_date
  end
end
