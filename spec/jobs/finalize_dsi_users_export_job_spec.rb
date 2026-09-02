require "rails_helper"

RSpec.describe FinalizeDSIUsersExportJob do
  let(:run) { DSIExportRun.create!(source: "users", total_pages: 2) }
  let(:users_service) { instance_double(Publishers::DfeSignIn::BigQueryExport::Users, insert_pages: nil) }

  before do
    allow(Publishers::DfeSignIn::BigQueryExport::Users).to receive(:new).and_return(users_service)

    run.dsi_export_run_pages.create!(page_number: 2, payload: [{ "userId" => "b" }])
    run.dsi_export_run_pages.create!(page_number: 1, payload: [{ "userId" => "a" }])
  end

  it "replaces the table with every page's data, in page order" do
    described_class.perform_now(run.id)

    expect(users_service).to have_received(:insert_pages)
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

    expect(users_service).not_to have_received(:insert_pages)
  end

  it "fails the run if it is finalized without all pages present" do
    run.dsi_export_run_pages.destroy_all
    run.dsi_export_run_pages.create!(page_number: 1, payload: [])

    # ApplicationJob's retry_on intercepts the raise and re-enqueues rather than
    # propagating it, so the observable effect here is the run's status.
    described_class.perform_now(run.id)

    expect(run.reload).to be_failed
    expect(users_service).not_to have_received(:insert_pages)
  end
end
