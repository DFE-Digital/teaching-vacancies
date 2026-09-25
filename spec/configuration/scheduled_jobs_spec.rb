require "rails_helper"

RSpec.describe "Scheduled jobs configuration" do
  let(:all_app_jobs) do
    # Require all jobs in case autoloading didn't get there
    Rails.root.join("app/jobs").glob("**/*.rb").map { |file| require file }

    ApplicationJob.descendants.map(&:name)
  end
  let(:gem_jobs) { [DfE::Analytics::Jobs::EntityTableCheckJob].map(&:to_s) }
  let(:scheduled_jobs) { YAML.load_file("./config/recurring.yml").fetch("production").values.pluck("class").uniq.compact }
  let(:unscheduled_jobs) do
    [
      AlertEmail::Base,
      RemoveGoogleIndexQueueJob,
      SeedDatabaseJob,
      SendJobListingEndedEarlyNotificationJob,
      UpdateGoogleIndexQueueJob,
      Noticed::DeliveryMethods::Email,
      Sentry::SendEventJob,
      SetOrganisationSlugsJob,
      SetOrganisationSlugsOfBatchJob,
      ImportFromVacancySourceJob,
      EqualOpportunitiesReportUpdateJob,
      SetSubscriptionLocationDataJob,
      UpdateSingleDSIUserInDbJob,
      FetchMalwareScanResultJob,
      SendJobAlertsJob,
    ].map(&:to_s)
  end

  it "includes all scheduled jobs in the schedule" do
    expect(scheduled_jobs).to match_array(all_app_jobs + gem_jobs - unscheduled_jobs)
  end
end
