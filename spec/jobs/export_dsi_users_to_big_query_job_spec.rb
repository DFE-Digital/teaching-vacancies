require "rails_helper"

RSpec.describe ExportDSIUsersToBigQueryJob do
  subject(:job) { described_class.perform_later }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context "when DisableExpensiveJobs is not enabled" do
    let(:disable_expensive_jobs_enabled?) { false }

    it "invokes the libs to export users and approvers to big query" do
      export_dsi_users_to_big_query = double(:export_dsi_users_to_big_query)
      expect(ExportDSIUsersToBigQuery).to receive(:new) { export_dsi_users_to_big_query }
      expect(export_dsi_users_to_big_query).to receive(:run!)

      export_dsi_approvers_to_big_query = double(:export_dsi_approvers_to_big_query)
      expect(ExportDSIApproversToBigQuery).to receive(:new) { export_dsi_approvers_to_big_query }
      expect(export_dsi_approvers_to_big_query).to receive(:run!)

      perform_enqueued_jobs { job }
    end
  end

  context "when DisableExpensiveJobs is enabled" do
    let(:disable_expensive_jobs_enabled?) { true }

    it "does not perform the job" do
      expect(ExportDSIUsersToBigQuery).not_to receive(:new)
      expect(ExportDSIApproversToBigQuery).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
