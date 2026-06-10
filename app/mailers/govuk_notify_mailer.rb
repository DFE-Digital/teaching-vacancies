class GovukNotifyMailer < Mail::Notify::Mailer
  SIDEKIQ_WORKER_COUNT = 4
  # Maximum rate we can send through production Govuk Notify is 3000 - reduce it a bit so we don't hit the limit
  GOVUK_NOTIFY_SEND_LIMIT_PER_MINUTE = 2800

  helper NotifyViewsHelper
  include MailerAnalyticsEvents

  helper_method :uid, :utm_campaign

  after_action :trigger_dfe_analytics_email_event

  # This line clearly cannot be auto-tested
  # :nocov:
  self.delivery_method = :notify unless Rails.env.test?

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
