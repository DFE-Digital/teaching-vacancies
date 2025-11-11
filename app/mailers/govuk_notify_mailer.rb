class GovukNotifyMailer < Mail::Notify::Mailer
  helper NotifyViewsHelper
  include MailerAnalyticsEvents

  helper_method :uid, :utm_campaign

  after_action :trigger_dfe_analytics_email_event

  # :nocov:
  self.delivery_method = :notify unless Rails.env.test?

  self.delivery_job = GovukNotifyMailerJob

  def send_email(to:, subject:)
    @to = to
    view_mail(template, to: to, subject: subject)
  end
  # :nocov:

  private

  attr_reader :to

  def template
    NOTIFY_PRODUCTION_TEMPLATE
  end
end
