require "rails_helper"

RSpec.describe FetchDSIUsersPageJob do
  let(:run) { DSIExportRun.create!(source: "db_sync", total_pages: 2) }
  let(:dsi_user) { { "userId" => SecureRandom.uuid } }

  before do
    fetch_dsi_users = instance_double(Publishers::DfeSignIn::FetchDSIUsers)
    allow(Publishers::DfeSignIn::FetchDSIUsers).to receive(:new).and_return(fetch_dsi_users)
    allow(fetch_dsi_users).to receive(:dsi_users_page).with(2).and_return([dsi_user])
  end

  it "fetches just the given page and enqueues an UpdateSingleDSIUserInDbJob per user on it" do
    expect { described_class.perform_now(run.id, 2) }
      .to have_enqueued_job(UpdateSingleDSIUserInDbJob).with(dsi_user)
  end

  it "marks the page as done against the run" do
    described_class.perform_now(run.id, 2)

    expect(run.dsi_export_run_pages.find_by(page_number: 2)).to be_present
  end

  it "does not complete the run until every page has arrived" do
    described_class.perform_now(run.id, 2)

    expect(run.reload).to be_running
  end

  it "marks the run completed once the last page arrives" do
    run.dsi_export_run_pages.create!(page_number: 1, payload: [])

    described_class.perform_now(run.id, 2)

    expect(run.reload).to be_completed
  end

  it "is idempotent when retried after already marking the page done" do
    described_class.perform_now(run.id, 2)

    expect { described_class.perform_now(run.id, 2) }.not_to change(DSIExportRunPage, :count)
  end
end
