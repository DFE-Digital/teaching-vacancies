# frozen_string_literal: true

class SidekiqJob < ApplicationJob
  # simplecov:disable
  self.queue_adapter = :sidekiq unless Rails.env.test?
  # simplecov:enable
end
