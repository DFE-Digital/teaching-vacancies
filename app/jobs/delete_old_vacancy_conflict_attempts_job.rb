class DeleteOldVacancyConflictAttemptsJob < ApplicationJob
  queue_as :default

  def perform
    # Delete records older than 13 months (September to September retention period)
    VacancyConflictAttempt.where(created_at: ..13.months.ago).delete_all
  end
end
