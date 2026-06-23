class SeedDatabaseJob < SolidQueueJob
  queue_as :low

  def perform
    Rails.application.load_tasks
    Rake::Task["db:seed"].invoke
  end
end
