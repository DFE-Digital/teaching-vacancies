require "rails_helper"

RSpec.describe "Sidekiq configuration" do
  let(:all_jobs) do
    # Require all jobs in case autoloading didn't get there
    Rails.root.join("app/jobs").glob("**/*.rb").map { |file| require file }

    ApplicationJob.descendants.map(&:name)
  end

  let(:scheduled_jobs) { YAML.load_file("./config/schedule.yml").map { |_, v| v["class"] } }
  let(:unscheduled_jobs) do
    %w[
      AlertEmail::Base
      MigrateVacancyDocumentsToActiveStorageJob
      NormaliseExistingOrganisationLogoDimensionsJob
      PerformancePlatformTransactionsQueueJob
      RemoveGoogleIndexQueueJob
      SeedDatabaseJob
      SendEventToDataWarehouseJob
      SendJobListingEndedEarlyNotificationJob
      UpdateGoogleIndexQueueJob
      Noticed::DeliveryMethods::Base
      Noticed::DeliveryMethods::Database
      Noticed::DeliveryMethods::Email
      Sentry::SendEventJob
      SetOrganisationSlugsJob
      SetOrganisationSlugsOfBatchJob
    ]
  end

  it "includes all scheduled jobs in the schedule" do
    expect(scheduled_jobs).to match_array(all_jobs - unscheduled_jobs)
  end
end
