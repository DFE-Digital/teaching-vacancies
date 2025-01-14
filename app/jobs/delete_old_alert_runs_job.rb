class DeleteOldAlertRunsJob < ApplicationJob
  queue_as :low

  def perform
    AlertRun.where(run_on: ...1.week.ago).destroy_all
  end
end
