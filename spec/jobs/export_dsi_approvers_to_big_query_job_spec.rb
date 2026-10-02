require "rails_helper"

RSpec.describe ExportDSIApproversToBigQueryJob do
  subject(:job) { described_class.perform_later }

  let(:dsi_approver) { build(:dsi_approver, user_id: "2") }

  before { allow(DfeSignIn::API).to receive(:approvers).and_return([dsi_approver].each) }

  it "syncs the DSI approvers into dsi_approvers" do
    expect(BigQuery::TableSync).to receive(:call) do |table:, key:, rows:|
      expect(table).to eq("dsi_approvers")
      expect(key).to eq(%i[user_id school_urn trust_uid la_code role_id])
      expect(rows.to_a).to eq([DfeSignIn::UserRows.new(dsi_approver).approver_row])
    end

    perform_enqueued_jobs { job }
  end

  context "when DisableIntegrations is enabled", :disable_integrations do
    it "does not call the DSI API or BigQuery" do
      expect(DfeSignIn::API).not_to receive(:approvers)
      expect(BigQuery::TableSync).not_to receive(:call)

      perform_enqueued_jobs { job }
    end
  end
end
