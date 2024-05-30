require "rails_helper"

RSpec.describe ExportDSIUsersToBigQueryJob do
  subject(:job) { described_class.perform_later }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context "when DisableExpensiveJobs is not enabled" do
    let(:disable_expensive_jobs_enabled?) { false }

    it "invokes the libs to export users and approvers to big query" do
      export_dsi_users_to_big_query = instance_double(Publishers::DfeSignIn::BigQueryExport::Users)
      expect(Publishers::DfeSignIn::BigQueryExport::Users).to receive(:new) { export_dsi_users_to_big_query }
      expect(export_dsi_users_to_big_query).to receive(:call)

      export_dsi_approvers_to_big_query = instance_double(Publishers::DfeSignIn::BigQueryExport::Approvers)
      expect(Publishers::DfeSignIn::BigQueryExport::Approvers).to receive(:new) { export_dsi_approvers_to_big_query }
      expect(export_dsi_approvers_to_big_query).to receive(:call)

      perform_enqueued_jobs { job }
    end
  end

  context "when DisableExpensiveJobs is enabled" do
    let(:disable_expensive_jobs_enabled?) { true }

    it "does not perform the job" do
      expect(Publishers::DfeSignIn::BigQueryExport::Users).not_to receive(:new)
      expect(Publishers::DfeSignIn::BigQueryExport::Approvers).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
