# frozen_string_literal: true

class ApplicationMailDeliveryJob < ActionMailer::MailDeliveryJob
  # Controls whether Active Job's `#perform_later` and similar methods automatically defer
  # the job queuing to after the current Active Record transaction is committed.
  # Moved here in Rails 8.0 as global setting was deprecated
  self.enqueue_after_transaction_commit = true
end
