class SeedDatabaseJob < ApplicationJob
  queue_as :low

  def perform
    # simplecov:disable
    Rails.application.load_tasks unless Rails.env.test? # This is pre-called in test mode
    # simplecov:enable
    Rake::Task["db:seed"].invoke
  end
end
