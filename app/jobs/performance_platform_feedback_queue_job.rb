require 'performance_platform_sender'

class PerformancePlatformFeedbackQueueJob < ApplicationJob
  queue_as :performance_platform

  def perform(time_to_s)
    PerformancePlatformSender::Base.by_type(:feedback).call(date: time_to_s)
  end
end
