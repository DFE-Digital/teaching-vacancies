class ResetSessionsJob < ApplicationJob
  queue_as :low

  def perform
    # Loading the tasks again would add a second copy of every task's actions.
    Rails.application.load_tasks unless Rake::Task.task_defined?("db:sessions:trim")
    Rake::Task["db:sessions:trim"].invoke
  end
end
