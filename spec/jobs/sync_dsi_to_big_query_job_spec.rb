require "rails_helper"

RSpec.describe SyncDSIToBigQueryJob do
  describe "#perform" do
    context "with the users table argument" do
      subject(:job) { described_class.perform_later("users") }

      it "syncs DfeSignIn::API.users, mapped through UserRows.for_users, into dsi_users" do
        dsi_user = build(:dsi_user, user_id: "1")
        mapped_row = { user_id: "1" }
        allow(DfeSignIn::API).to receive(:users).and_return([dsi_user].each)
        allow(DfeSignIn::UserRows).to receive(:for_users).with(dsi_user).and_return(mapped_row)

        expect(BigQuery::TableSync).to receive(:call) do |table:, rows:, **|
          expect(table).to eq("dsi_users")
          expect(rows.to_a).to eq([mapped_row])
        end
        perform_enqueued_jobs { job }
      end
    end

    context "with the approvers table argument" do
      subject(:job) { described_class.perform_later("approvers") }

      # Not a full duplicate of the users case above — just enough to prove the argument
      # actually selects a different source/mapper/table triple, which is the one thing
      # that's new versus having two separate job classes.
      it "syncs DfeSignIn::API.approvers, mapped through UserRows.for_approvers, into dsi_approvers" do
        allow(DfeSignIn::API).to receive(:approvers).and_return([].each)
        expect(BigQuery::TableSync).to receive(:call).with(hash_including(table: "dsi_approvers"))

        perform_enqueued_jobs { job }
      end
    end

    context "with an unrecognised table argument" do
      # Config-driven jobs (a hash of table => {source, mapper}) fail silently on a typo
      # unless something asserts the lookup itself. Worth one spec so a future typo in
      # recurring.yml raises loudly instead of running .call on nil.
      #
      # Calls #perform directly rather than going through perform_later/perform_enqueued_jobs:
      # ApplicationJob registers retry_on StandardError, so a typo'd table name enqueued
      # the normal way wouldn't raise here at all — it'd be silently retried 8 times over
      # ~75 minutes before finally surfacing (wrapped in Minitest::UnexpectedError, not as
      # a bare ArgumentError). That's a real, if slow, failure mode of its own, but it's
      # ApplicationJob's retry behaviour being exercised, not this job's argument handling,
      # which is what this spec is actually about.
      it "raises rather than silently doing nothing" do
        expect { described_class.new.perform("nonexistent") }.to raise_error(ArgumentError)
      end
    end

    context "when DisableIntegrations is enabled", :disable_integrations do
      it "does not call the DSI API or BigQuery at all" do
        expect(DfeSignIn::API).not_to receive(:users)
        expect(BigQuery::TableSync).not_to receive(:call)

        perform_enqueued_jobs { described_class.perform_later("users") }
      end
    end
  end
end
