class GovukNotifyMailer < Mail::Notify::Mailer
  SIDEKIQ_WORKER_COUNT = 4
  # This is the maximum rate we can send through production Govuk Notify
  GOVUK_NOTIFY_SEND_LIMIT_PER_MINUTE = 3000

  helper NotifyViewsHelper
  include MailerAnalyticsEvents

  helper_method :uid, :utm_campaign

  after_action :trigger_dfe_analytics_email_event

  # :nocov:
  self.delivery_method = :notify unless Rails.env.test?

  # inspired by https://mattbrictson.com/blog/applying-a-rate-limit-in-sidekiq

  extend Limiter::Mixin

  # this should send 1 per minute (60 calls balanaced over 1 hour)
  limit_method :send_email, rate: 60, interval: 3600, balanced: true

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
