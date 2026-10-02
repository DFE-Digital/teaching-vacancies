require "rails_helper"

RSpec.describe ExportDSIUsersToBigQueryJob do
  subject(:job) { described_class.perform_later }

  let(:dsi_user) { build(:dsi_user, user_id: "1") }

  before { allow(DfeSignIn::API).to receive(:users).and_return([dsi_user].each) }

  it "syncs the DSI users into dsi_users" do
    expect(BigQuery::TableSync).to receive(:call) do |table:, key:, rows:|
      expect(table).to eq("dsi_users")
      expect(key).to eq(%i[user_id school_urn trust_uid la_code])
      expect(rows.to_a).to eq([DfeSignIn::UserRows.new(dsi_user).user_row])
    end

    perform_enqueued_jobs { job }
  end

  context "when DisableIntegrations is enabled", :disable_integrations do
    it "does not call the DSI API or BigQuery" do
      expect(DfeSignIn::API).not_to receive(:users)
      expect(BigQuery::TableSync).not_to receive(:call)

      perform_enqueued_jobs { job }
    end
  end
end
