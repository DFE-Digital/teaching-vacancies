require "rails_helper"

RSpec.describe ExportTablesToBigQueryJob, type: :job do
  subject(:job) { described_class.perform_later }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context "when DisableExpensiveJobs is not enabled" do
    let(:disable_expensive_jobs_enabled?) { false }

    it "calls the export tables to big query class" do
      export_tables_to_bigquery = double(:export_tables_to_bigquery)
      expect(ExportTablesToBigQuery).to receive(:new) { export_tables_to_bigquery }
      expect(export_tables_to_bigquery).to receive(:run!)

      perform_enqueued_jobs { job }
    end
  end

  context "when DisableExpensiveJobs is enabled" do
    let(:disable_expensive_jobs_enabled?) { true }

    it "does not perform the job" do
      expect(ExportTablesToBigQuery).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
