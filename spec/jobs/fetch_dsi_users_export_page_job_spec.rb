require "rails_helper"

RSpec.describe FetchDSIUsersExportPageJob do
  let(:run) { DSIExportRun.create!(source: "users", total_pages: 2) }
  let(:page_1_users) { [{ "userId" => SecureRandom.uuid }] }

  before do
    fetch_dsi_users = instance_double(Publishers::DfeSignIn::FetchDSIUsers)
    allow(Publishers::DfeSignIn::FetchDSIUsers).to receive(:new).and_return(fetch_dsi_users)
    allow(fetch_dsi_users).to receive(:dsi_users_page).with(1).and_return(page_1_users)
  end

  it "caches the fetched page against the run" do
    described_class.perform_now(run.id, 1)

    run_page = run.dsi_export_run_pages.find_by(page_number: 1)
    expect(run_page.payload).to eq(page_1_users)
  end

  it "does not finalize the run until every page has arrived" do
    expect { described_class.perform_now(run.id, 1) }
      .not_to have_enqueued_job(FinalizeDSIUsersExportJob)
  end

  it "enqueues FinalizeDSIUsersExportJob once the last page arrives" do
    run.dsi_export_run_pages.create!(page_number: 2, payload: [])

    expect { described_class.perform_now(run.id, 1) }
      .to have_enqueued_job(FinalizeDSIUsersExportJob).with(run.id)
  end

  it "is idempotent when retried after already caching the page" do
    described_class.perform_now(run.id, 1)

    expect { described_class.perform_now(run.id, 1) }.not_to change(DSIExportRunPage, :count)
  end
end
