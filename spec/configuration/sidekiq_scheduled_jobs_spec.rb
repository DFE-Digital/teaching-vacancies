require "rails_helper"

RSpec.describe "Sidekiq configuration" do
  let(:all_app_jobs) do
    # Require all jobs in case autoloading didn't get there
    Rails.root.join("app/jobs").glob("**/*.rb").map { |file| require file }

    ApplicationJob.descendants.map(&:name)
  end
  let(:gem_jobs) { %w[DfE::Analytics::Jobs::EntityTableCheckJob] }
  let(:scheduled_jobs) { YAML.load_file("./config/schedule.yml").map { |_, v| v["class"] }.uniq }
  let(:unscheduled_jobs) do
    %w[
      AlertEmail::Base
      MigrateVacancyDocumentsToActiveStorageJob
      PerformancePlatformTransactionsQueueJob
      RemoveGoogleIndexQueueJob
      SeedDatabaseJob
      SendJobListingEndedEarlyNotificationJob
      UpdateGoogleIndexQueueJob
      Noticed::DeliveryMethods::Base
      Noticed::DeliveryMethods::Database
      Noticed::DeliveryMethods::Email
      Sentry::SendEventJob
      SendJobAlertsJob
      SetOrganisationSlugsJob
      SetOrganisationSlugsOfBatchJob
      ImportFromVacancySourceJob
      TrackVacancyViewJob
      EqualOpportunitiesReportUpdateJob
      BackfillSubscriptionLocationJob
      SetSubscriptionLocationDataJob
      RecomputeSubscriptionAreasJob
    ]
  end

  it "includes all scheduled jobs in the schedule" do
    expect(scheduled_jobs).to match_array(all_app_jobs + gem_jobs - unscheduled_jobs)
  end
end
