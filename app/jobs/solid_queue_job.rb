# frozen_string_literal: true

class SolidQueueJob < ApplicationJob
  # :nocov:
  # Set the adapter explicitly, otherwise this uses the default one (which might be sidekiq)
  self.queue_adapter = :sidekiq unless Rails.env.test?
  # :nocov:

  retry_on StandardError, attempts: 10
end
