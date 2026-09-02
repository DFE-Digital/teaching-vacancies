require "rails_helper"

RSpec.describe ExportDSIUsersToBigQueryJob do
  context "when DisableIntegrations is not enabled" do
    it "creates a run and fans out one FetchDSIUsersExportPageJob per page" do
      fetch_dsi_users = instance_double(Publishers::DfeSignIn::FetchDSIUsers, dsi_users_page_count: 3)
      allow(Publishers::DfeSignIn::FetchDSIUsers).to receive(:new).and_return(fetch_dsi_users)

      expect { described_class.perform_now }
        .to change(DSIExportRun, :count).by(1)
        .and have_enqueued_job(FetchDSIUsersExportPageJob).exactly(3).times

      run = DSIExportRun.last
      expect(run.source).to eq("users")
      expect(run.total_pages).to eq(3)
      expect(run).to be_running
    end

    it "does not start a new run while a users export is already running" do
      DSIExportRun.create!(source: "users", total_pages: 5)

      expect(Publishers::DfeSignIn::FetchDSIUsers).not_to receive(:new)

      expect { described_class.perform_now }.not_to change(DSIExportRun, :count)
    end
  end

  context "when DisableIntegrations is enabled", :disable_integrations do
    it "does not perform the job" do
      expect(Publishers::DfeSignIn::FetchDSIUsers).not_to receive(:new)

      described_class.perform_now
    end
  end
end
