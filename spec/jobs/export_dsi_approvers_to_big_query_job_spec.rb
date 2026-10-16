require "rails_helper"

RSpec.describe ExportDSIApproversToBigQueryJob do
  subject(:job) { described_class.perform_later }

  let(:dsi_approver) { build(:dsi_approver, :trust, user_id: "user-2", trust_uid: "555") }

  let(:table) { instance_double(BigQuery::Table, replace: nil) }

  before do
    allow(DfeSignIn::API).to receive(:approvers).and_return([dsi_approver].each)
    allow(BigQuery::Table).to receive(:new).and_return(table)
  end

  it "replaces dsi_approvers with the DSI approvers" do
    perform_enqueued_jobs { job }

    expect(BigQuery::Table).to have_received(:new).with("dsi_approvers", schema: anything)
    expect(table).to have_received(:replace).once
  end

  it "maps the approver shape, which has no timestamps and an extra role_id" do
    perform_enqueued_jobs { job }

    expect(table).to have_received(:replace).with([
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

      expect(table).to have_received(:replace)
        .with([a_hash_including(school_urn: 100_001, trust_uid: nil)])
    end
  end

  context "with a local authority approver" do
    let(:dsi_approver) { build(:dsi_approver, :local_authority, establishment_number: "801") }

    it "maps the LA code" do
      perform_enqueued_jobs { job }

      expect(table).to have_received(:replace)
        .with([a_hash_including(la_code: 801, school_urn: nil)])
    end
  end

  # DSI lists some approvers with no name or email, so those columns are nullable.
  it "defines every column, masking the personal data" do
    table_schema = nil
    allow(BigQuery::Table).to receive(:new) do |_name, **options|
      table_schema = options[:schema]
      table
    end
    perform_enqueued_jobs { job }
    schema = instance_spy(Google::Cloud::Bigquery::LoadJob::Updater)
    table_schema.call(schema)

    expect(schema).to have_received(:string).with("email", mode: :nullable, policy_tags: [described_class::POLICY_TAG_MASKED]).ordered
    expect(schema).to have_received(:string).with("family_name", mode: :nullable, policy_tags: [described_class::POLICY_TAG_MASKED]).ordered
    expect(schema).to have_received(:string).with("given_name", mode: :nullable, policy_tags: [described_class::POLICY_TAG_MASKED]).ordered
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
      expect(table).not_to have_received(:replace)
    end
  end
end
