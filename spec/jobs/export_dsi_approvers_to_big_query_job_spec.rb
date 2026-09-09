require "rails_helper"

RSpec.describe ExportDSIApproversToBigQueryJob do
  subject(:job) { described_class.perform_later }

  context "when DisableIntegrations is not enabled" do
    it "invokes the lib to export approvers to big query" do
      export_dsi_approvers_to_big_query = instance_double(Publishers::DfeSignIn::BigQueryExport::Approvers, call: nil)
      allow(Publishers::DfeSignIn::BigQueryExport::Approvers).to receive(:new).and_return(export_dsi_approvers_to_big_query)

      perform_enqueued_jobs { job }

      expect(export_dsi_approvers_to_big_query).to have_received(:call)
    end
  end

  context "when DisableIntegrations is enabled", :disable_integrations do
    it "does not perform the job" do
      expect(Publishers::DfeSignIn::BigQueryExport::Approvers).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
