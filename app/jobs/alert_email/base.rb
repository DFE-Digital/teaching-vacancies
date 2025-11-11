# frozen_string_literal: true

class AlertEmail::Base < ApplicationJob
  BATCH_SIZE = 5000

  def perform
    return if DisableEmailNotifications.enabled?

    subscriptions.find_in_batches(batch_size: BATCH_SIZE).each do |batch|
      SendJobAlertsJob.perform_later self.class.name, batch, from_date
    end
  end
end
