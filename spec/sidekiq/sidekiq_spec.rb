require "rails_helper"

RSpec.describe "Sidekiq configuration" do
  let(:all_jobs) do
    # Require all jobs in case autoloading didn't get there
    Rails.root.join("app/jobs").glob("**/*.rb").map { |file| require file }

    ActiveJob::Base.descendants.map(&:name)
  end

  let(:scheduled_jobs) { YAML.load_file("./config/schedule.yml").map { |_, v| v["class"] } }
  let(:unscheduled_jobs) do
    %w[
      ActionMailer::DeliveryJob
      ActionMailer::MailDeliveryJob
      ActionMailer::Parameterized::DeliveryJob
      ActiveRecord::DestroyAssociationAsyncJob
      AlertEmail::Base
      AlertMailerJob
      AuditExpressInterestEventJob
      AuditPublishedVacancyJob
      AuditSearchEventJob
      PerformancePlatformTransactionsQueueJob
      PersistVacancyGetMoreInfoClickJob
      PersistVacancyPageViewJob
      RemoveGoogleIndexQueueJob
      SendEventToDataWarehouseJob
      UpdateGoogleIndexQueueJob
    ]
  end

  it "includes all scheduled jobs in the schedule" do
    expect(scheduled_jobs).to match_array(all_jobs - unscheduled_jobs)
  end
end
