# frozen_string_literal: true

class SidekiqJob < ApplicationJob
  # :nocov:
  self.queue_adapter = :sidekiq unless Rails.env.test?
  # :nocov:
end
