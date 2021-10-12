class SeedDatabaseJob < ApplicationJob
  queue_as :low

  def perform
    ImportOrganisationDataJob.perform_now
    Rails.application.load_tasks
    Rake::Task["db:seed"].invoke
  end
end
