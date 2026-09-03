require "rails_helper"

RSpec.describe DSIExportRunPage do
  subject(:run_page) { described_class.new(dsi_export_run: run, page_number: 1, payload: [{ "id" => 1 }]) }

  let(:run) { DSIExportRun.create!(source: "users", total_pages: 1) }

  it { is_expected.to belong_to(:dsi_export_run) }
  it { is_expected.to validate_presence_of(:page_number) }

  it "is invalid if the run already has a page with the same number" do
    run_page.save!

    duplicate = described_class.new(dsi_export_run: run, page_number: 1, payload: [])

    expect(duplicate).not_to be_valid
  end

  it "is invalid if payload is nil" do
    run_page.payload = nil

    expect(run_page).not_to be_valid
  end

  it "is valid with an empty payload" do
    run_page.payload = []

    expect(run_page).to be_valid
  end
end
