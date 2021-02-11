class SubmitPerformancePlatformJob < ActiveJob::Base
  queue_as :low

  def perform
    Rails.application.load_tasks
    Rake::Task["performance_platform:submit_transactions"].invoke
  end
end
