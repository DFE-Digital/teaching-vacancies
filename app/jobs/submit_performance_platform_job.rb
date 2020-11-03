class SubmitPerformancePlatformJob < ApplicationJob
  queue_as :submit_performance_platform

  def perform
    Rails.application.load_tasks
    Rake::Task["performance_platform:submit_transactions"].invoke
  end
end
