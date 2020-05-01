class ResetSessionsJob < ApplicationJob
  queue_as :reset_sessions

  def perform
    Rails.application.load_tasks
    Rake::Task['db:sessions:trim'].invoke
  end
end
