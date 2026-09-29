class ResetSessionsJob < ApplicationJob
  queue_as :low

  def perform
    Rake::Task["db:sessions:trim"].invoke
  end
end
