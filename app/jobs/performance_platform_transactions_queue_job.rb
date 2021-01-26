require "performance_platform_sender"

class PerformancePlatformTransactionsQueueJob < ApplicationJob
  queue_as :low

  def perform(time_to_s)
    PerformancePlatformSender::Base.by_type(:transactions).call(date: time_to_s)
  end
end
