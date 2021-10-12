class SeedDatabaseJob < ApplicationJob
  queue_as :low

  def perform
    if Organisation.none?
      Gias::ImportSchoolsAndLocalAuthorities.new.call
      Gias::ImportTrusts.new.call
    end
    Rails.application.load_tasks
    Rake::Task["db:seed"].invoke
  end
end
