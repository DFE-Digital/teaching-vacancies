require "rails_helper"

RSpec.describe UpdateDSIUsersInDbJob do
  it "creates a run and fans out one FetchDSIUsersPageJob per page" do
    fetch_dsi_users = instance_double(Publishers::DfeSignIn::FetchDSIUsers, dsi_users_page_count: 3)
    allow(Publishers::DfeSignIn::FetchDSIUsers).to receive(:new).and_return(fetch_dsi_users)

    expect { described_class.perform_now }.to change(DSIExportRun, :count).by(1)

    run = DSIExportRun.last
    expect(run.source).to eq("db_sync")
    expect(run.total_pages).to eq(3)
    expect(run).to be_running
    expect(enqueued_jobs.pluck(:args)).to contain_exactly([run.id, 1], [run.id, 2], [run.id, 3])
  end

  it "does not start a new run while a db sync is already running" do
    DSIExportRun.create!(source: "db_sync", total_pages: 5)

    expect(Publishers::DfeSignIn::FetchDSIUsers).not_to receive(:new)

    expect { described_class.perform_now }.not_to change(DSIExportRun, :count)
  end
end
