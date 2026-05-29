# frozen_string_literal: true

class MailSendingJob < ActionMailer::MailDeliveryJob
  queue_as :notify

  # don't run more than 90% of mailer API throttle
  # limits_concurrency to: GOVUK_NOTIFY_SEND_LIMIT_PER_MINUTE * 0.9, key: "notify", duration: 1.minute
end
