require "rails_helper"

RSpec.describe FinalizeDSIApproversExportJob do
  let(:run) { DSIExportRun.create!(source: "approvers", total_pages: 2) }
  let(:approvers_service) { instance_double(Publishers::DfeSignIn::BigQueryExport::Approvers, insert_pages: nil) }

  before do
    allow(Publishers::DfeSignIn::BigQueryExport::Approvers).to receive(:new).and_return(approvers_service)

    run.dsi_export_run_pages.create!(page_number: 2, payload: [{ "userId" => "b" }])
    run.dsi_export_run_pages.create!(page_number: 1, payload: [{ "userId" => "a" }])
  end

  it "replaces the table with every page's data, in page order" do
    described_class.perform_now(run.id)

    expect(approvers_service).to have_received(:insert_pages)
      .with([[{ "userId" => "a" }], [{ "userId" => "b" }]])
  end

  it "marks the run completed and clears the cached pages" do
    described_class.perform_now(run.id)

    expect(run.reload).to be_completed
    expect(run.dsi_export_run_pages).to be_empty
  end

  it "does nothing if the run is not currently running (already claimed by another attempt)" do
    run.update!(status: :finalizing)

    described_class.perform_now(run.id)

    expect(approvers_service).not_to have_received(:insert_pages)
  end

  it "fails the run if it is finalized without all pages present" do
    run.dsi_export_run_pages.destroy_all
    run.dsi_export_run_pages.create!(page_number: 1, payload: [])

    described_class.perform_now(run.id)

    expect(run.reload).to be_failed
    expect(approvers_service).not_to have_received(:insert_pages)
  end
end
