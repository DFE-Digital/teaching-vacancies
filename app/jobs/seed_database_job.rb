class SeedDatabaseJob < ApplicationJob
  queue_as :low

  def perform
    Rake::Task["db:seed"].invoke
  end
end
