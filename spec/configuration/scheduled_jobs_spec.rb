require "rails_helper"

RSpec.describe "Scheduled jobs configuration" do
  let(:all_app_jobs) do
    # Require all jobs in case autoloading didn't get there
    Rails.root.join("app/jobs").glob("**/*.rb").map { |file| require file }

    ApplicationJob.descendants.map(&:name)
  end
  let(:gem_jobs) { %w[DfE::Analytics::Jobs::EntityTableCheckJob] }
  let(:scheduled_jobs) { YAML.load_file("./config/schedule.yml").map { |_, v| v["class"] }.uniq.compact }
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
      MigratePersonalStatementJob
      UpdateSingleDSIUserInDbJob
      FetchMalwareScanResultJob
      SidekiqJob
      SolidQueueJob
    ]
  end
  # TODO: this is temporary until we move all scheduled jobs to solid queue
  let(:solid_queue_jobs) { %w[AggregateVacancyReferrerStatsJob] }

  it "includes all scheduled jobs in the schedule" do
    expect(scheduled_jobs).to match_array(all_app_jobs + gem_jobs - unscheduled_jobs - solid_queue_jobs)
  end
end
