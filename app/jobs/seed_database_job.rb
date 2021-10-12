class SeedDatabaseJob < ApplicationJob
  queue_as :low

  def perform
    Gias::ImportSchoolsAndLocalAuthorities.new.call
    Gias::ImportTrusts.new.call
    Rails.application.load_tasks
    Rake::Task["db:seed"].invoke
  end
end
