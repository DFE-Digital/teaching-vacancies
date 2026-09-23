require "rails_helper"

RSpec.describe ExportDSIApproversToBigQueryJob do
  subject(:job) { described_class.perform_later }

  let(:dsi_approver) { build(:dsi_approver, :trust, user_id: "user-2", trust_uid: "555") }
  let(:synced) { {} }

  before do
    allow(DfeSignIn::API).to receive(:approvers).and_return([dsi_approver].each)
    allow(BigQuery::TableSync).to receive(:call) { |table:, rows:| synced.merge!(table:, rows:) }
  end

  it "syncs the DSI approvers into dsi_approvers, matching rows on their role as well as their organisation" do
    perform_enqueued_jobs { job }

    expect(synced[:table].name).to eq("dsi_approvers")
    expect(synced[:table].key).to eq(%i[user_id school_urn trust_uid la_code role_id])
  end

  it "maps the approver shape, which has no timestamps and an extra role_id" do
    perform_enqueued_jobs { job }

    expect(synced[:rows]).to eq([
      {
        email: dsi_approver["email"],
        family_name: dsi_approver["familyName"],
        given_name: dsi_approver["givenName"],
        la_code: nil,
        trust_uid: 555,
        role_id: "approver",
        role_name: "Approver",
        school_urn: nil,
        user_id: "user-2",
      },
    ])
  end

  context "with a school approver" do
    let(:dsi_approver) { build(:dsi_approver, school_urn: "100001") }

    it "maps the school URN" do
      perform_enqueued_jobs { job }

      expect(synced[:rows].sole).to include(school_urn: 100_001, trust_uid: nil)
    end
  end

  context "with a local authority approver" do
    let(:dsi_approver) { build(:dsi_approver, :local_authority, establishment_number: "801") }

    it "maps the LA code" do
      perform_enqueued_jobs { job }

      expect(synced[:rows].sole).to include(la_code: 801, school_urn: nil)
    end
  end

  it "defines every column, masking the personal data" do
    perform_enqueued_jobs { job }
    schema = instance_spy(Google::Cloud::Bigquery::LoadJob::Updater)
    synced[:table].schema.call(schema)

    expect(schema).to have_received(:string).with("email", mode: :required, policy_tags: [described_class::POLICY_TAG_MASKED]).ordered
    expect(schema).to have_received(:string).with("family_name", mode: :required, policy_tags: [described_class::POLICY_TAG_MASKED]).ordered
    expect(schema).to have_received(:string).with("given_name", mode: :required, policy_tags: [described_class::POLICY_TAG_MASKED]).ordered
    expect(schema).to have_received(:integer).with("la_code", mode: :nullable).ordered
    expect(schema).to have_received(:string).with("role_id", mode: :required).ordered
    expect(schema).to have_received(:string).with("role_name", mode: :required).ordered
    expect(schema).to have_received(:integer).with("school_urn", mode: :nullable).ordered
    expect(schema).to have_received(:integer).with("trust_uid", mode: :nullable).ordered
    expect(schema).to have_received(:string).with("user_id", mode: :required).ordered
  end

  context "when DisableIntegrations is enabled", :disable_integrations do
    it "does not call the DSI API or BigQuery" do
      perform_enqueued_jobs { job }

      expect(DfeSignIn::API).not_to have_received(:approvers)
      expect(BigQuery::TableSync).not_to have_received(:call)
    end
  end
end
