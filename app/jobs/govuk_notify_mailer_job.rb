class GovukNotifyMailerJob < ActionMailer::MailDeliveryJob
  queue_as :notify

  # inspired by https://mattbrictson.com/blog/applying-a-rate-limit-in-sidekiq

  extend Limiter::Mixin

  limit_method :perform, rate: 3000, interval: 60, balanced: true
end
