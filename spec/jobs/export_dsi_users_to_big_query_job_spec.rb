require "rails_helper"

RSpec.describe ExportDSIUsersToBigQueryJob do
  subject(:job) { described_class.perform_later }

  let(:dsi_user) do
    build(:dsi_user, user_id: "user-1", role_name: "End user", school_urn: "100000",
                     approved_at: "2026-01-01T09:30:00.000Z", updated_at: "2026-01-02T10:45:00.123Z")
  end

  let(:table) { instance_double(BigQuery::Table, replace: nil) }

  before do
    allow(DfeSignIn::API).to receive(:users).and_return([dsi_user].each)
    allow(BigQuery::Table).to receive(:new).and_return(table)
  end

  it "replaces dsi_users with the DSI users" do
    perform_enqueued_jobs { job }

    expect(BigQuery::Table).to have_received(:new).with("dsi_users", schema: anything)
    expect(table).to have_received(:replace).once
  end

  it "maps DSI's fields to typed columns" do
    perform_enqueued_jobs { job }

    expect(table).to have_received(:replace).with([
      {
        approval_datetime: Time.utc(2026, 1, 1, 9, 30),
        email: dsi_user["email"],
        family_name: dsi_user["familyName"],
        given_name: dsi_user["givenName"],
        la_code: nil,
        trust_uid: nil,
        role: "End user",
        school_urn: 100_000,
        update_datetime: Time.utc(2026, 1, 2, 10, 45, Rational(123, 1000)),
        user_id: "user-1",
      },
    ])
  end

  context "with a local authority user who has not been approved" do
    let(:dsi_user) { build(:dsi_user, :local_authority, establishment_number: "0800", approved_at: nil) }

    it "reads the LA code as a base 10 integer and leaves the missing timestamp empty" do
      perform_enqueued_jobs { job }

      expect(table).to have_received(:replace)
        .with([a_hash_including(la_code: 800, school_urn: nil, approval_datetime: nil)])
    end
  end

  context "with a trust user" do
    let(:dsi_user) { build(:dsi_user, :trust, trust_uid: "12345") }

    it "maps the trust UID" do
      perform_enqueued_jobs { job }

      expect(table).to have_received(:replace)
        .with([a_hash_including(trust_uid: 12_345, school_urn: nil)])
    end
  end

  context "when DSI sends a timestamp that isn't ISO 8601" do
    let(:dsi_user) { build(:dsi_user, updated_at: "yesterday") }

    it "raises rather than storing it as NULL" do
      expect { described_class.new.perform }.to raise_error(ArgumentError)
      expect(table).not_to have_received(:replace)
    end
  end

  it "defines every column, masking the personal data" do
    table_schema = nil
    allow(BigQuery::Table).to receive(:new) do |_name, **options|
      table_schema = options[:schema]
      table
    end
    perform_enqueued_jobs { job }
    schema = instance_spy(Google::Cloud::Bigquery::LoadJob::Updater)
    table_schema.call(schema)

    expect(schema).to have_received(:timestamp).with("approval_datetime", mode: :nullable).ordered
    expect(schema).to have_received(:string).with("email", mode: :nullable, policy_tags: [described_class::POLICY_TAG_MASKED]).ordered
    expect(schema).to have_received(:string).with("family_name", mode: :nullable, policy_tags: [described_class::POLICY_TAG_MASKED]).ordered
    expect(schema).to have_received(:string).with("given_name", mode: :nullable, policy_tags: [described_class::POLICY_TAG_MASKED]).ordered
    expect(schema).to have_received(:integer).with("la_code", mode: :nullable).ordered
    expect(schema).to have_received(:string).with("role", mode: :nullable).ordered
    expect(schema).to have_received(:integer).with("school_urn", mode: :nullable).ordered
    expect(schema).to have_received(:integer).with("trust_uid", mode: :nullable).ordered
    expect(schema).to have_received(:timestamp).with("update_datetime", mode: :nullable).ordered
    expect(schema).to have_received(:string).with("user_id", mode: :nullable).ordered
  end

  context "when DisableIntegrations is enabled", :disable_integrations do
    it "does not call the DSI API or BigQuery" do
      perform_enqueued_jobs { job }

      expect(DfeSignIn::API).not_to have_received(:users)
      expect(table).not_to have_received(:replace)
    end
  end
end
