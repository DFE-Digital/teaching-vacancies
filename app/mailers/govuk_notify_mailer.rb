class GovukNotifyMailer < Mail::Notify::Mailer
  helper NotifyViewsHelper
  include MailerAnalyticsEvents

  helper_method :uid, :utm_campaign

  after_action :trigger_dfe_analytics_email_event

  # :nocov:
  self.delivery_method = :notify unless Rails.env.test?

  # inspired by https://mattbrictson.com/blog/applying-a-rate-limit-in-sidekiq
  extend Limiter::Mixin

  # limit sending emails to 3000 per minute - but send in a burst, don't balance across the minute
  limit_method :send_email, rate: 3000, balanced: false

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
