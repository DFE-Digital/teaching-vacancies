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

  # use custom delivery job by default o that email jobs are not run until transaction commit
  self.delivery_job = ApplicationMailDeliveryJob

  # inspired by https://mattbrictson.com/blog/applying-a-rate-limit-in-sidekiq
  extend Limiter::Mixin

  # limit sending emails to 3000 per minute - but send in a burst, don't balance across the minute
  # calculate as 3000 / worker_count to make it clear what's going on
  limit_method :send_email, rate: GOVUK_NOTIFY_SEND_LIMIT_PER_MINUTE / SIDEKIQ_WORKER_COUNT, balanced: false

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
