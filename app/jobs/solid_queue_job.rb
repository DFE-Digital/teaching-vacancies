# frozen_string_literal: true

class SolidQueueJob < ApplicationJob
  retry_on StandardError, attempts: 10
end
