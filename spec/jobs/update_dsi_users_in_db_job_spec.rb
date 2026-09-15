require "rails_helper"

RSpec.describe UpdateDSIUsersInDbJob do
  let(:page_1_path) { Rails.root.join("spec/fixtures/dfe_sign_in_service_users_response_page_1.json") }
  let(:page_2_path) { Rails.root.join("spec/fixtures/dfe_sign_in_service_users_response_page_2.json") }
  let(:page_1_users) { JSON.parse(File.read(page_1_path)).fetch("users") }
  let(:page_2_users) { JSON.parse(File.read(page_2_path)).fetch("users") }

  let(:fetch_dsi_users) do
    instance_double(Publishers::DfeSignIn::FetchDSIUsers, dsi_users_page_count: 2)
  end

  before do
    allow(Publishers::DfeSignIn::FetchDSIUsers).to receive(:new).and_return(fetch_dsi_users)
    allow(fetch_dsi_users).to receive(:dsi_users_page).with(1).and_return(page_1_users)
    allow(fetch_dsi_users).to receive(:dsi_users_page).with(2).and_return(page_2_users)
  end

  it "fetches every page and creates a publisher for each distinct user across them", :perform_enqueued do
    # page_2's fixture repeats "CCC-333" for multiple organisations, so the distinct users
    # across both pages (AAA-111, CCC-333, DEF-456) is fewer than the raw record count.
    expect { described_class.perform_later }.to change(Publisher, :count).by(3)
  end

  it "resumes from the next page instead of refetching an already-processed one" do
    described_class.perform_later

    interrupt_job_during_step(described_class, :sync_users, cursor: 2) { perform_enqueued_jobs }

    expect(fetch_dsi_users).to have_received(:dsi_users_page).with(1)
    expect(fetch_dsi_users).not_to have_received(:dsi_users_page).with(2)

    perform_enqueued_jobs

    expect(fetch_dsi_users).to have_received(:dsi_users_page).with(2)
  end
end
