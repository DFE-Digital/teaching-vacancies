require "rails_helper"

RSpec.describe FixMyNewTermExpiresAt do
  subject(:service) { described_class.call }

  let!(:ats_client) { create(:publisher_ats_api_client, name: "MyNewTerm") }
  let!(:other_client) { create(:publisher_ats_api_client, name: "OtherClient") }

  # Convenience helpers
  let(:bst_start_utc) { Time.utc(2026, 3, 29, 1, 0, 0) }
  let(:cutoff_utc) { Time.utc(2026, 4, 21, 9, 56, 0) }
  let(:bst_end_utc) { Time.utc(2026, 10, 25, 1, 0, 0) }

  # Within the created_at window
  let(:created_in_window) { bst_start_utc + 1.day }
  # Expires within BST window
  let(:expires_in_bst) { Time.utc(2026, 6, 1, 9, 0, 0) }

  def vacancy_for(client, created_at:, expires_at:)
    create(
      :vacancy,
      :external,
      publisher_ats_api_client: client,
      created_at: created_at,
      expires_at: expires_at,
    )
  end

  describe "#call" do
    before { travel_to(Time.utc(2026, 4, 22, 9, 0, 0)) }

    context "with a vacancy in the full window with expires_at inside BST" do
      it "reduces expires_at by 1 hour" do
        vacancy = vacancy_for(ats_client, created_at: created_in_window, expires_at: expires_in_bst)
        expect { service }.to change { vacancy.reload.expires_at }.by(-1.hour)
      end

      it "returns the count of fixed vacancies" do
        vacancy_for(ats_client, created_at: created_in_window, expires_at: expires_in_bst)
        vacancy_for(ats_client, created_at: created_in_window, expires_at: expires_in_bst + 1.day)
        expect(service).to eq(2)
      end
    end

    context "with a vacancy created before BST started but expiring within BST" do
      it "reduces expires_at by 1 hour" do
        vacancy = vacancy_for(ats_client, created_at: bst_start_utc - 1.day, expires_at: expires_in_bst)
        expect { service }.to change { vacancy.reload.expires_at }.by(-1.hour)
      end
    end

    context "with a vacancy that is already expired" do
      it "does not change expires_at" do
        vacancy = create(:vacancy, :external, :expired, publisher_ats_api_client: ats_client)
        # Force expires_at into the BST window (past) to confirm the filter excludes it
        past_bst_expiry = Time.utc(2026, 4, 10, 9, 0, 0)
        vacancy.update_columns(created_at: created_in_window, expires_at: past_bst_expiry)
        expect { service }.not_to(change { vacancy.reload.expires_at })
      end
    end

    context "with a vacancy created at or after the cutoff (10:56 BST / 09:56 UTC on 21 Apr)" do
      it "does not change expires_at when created exactly at cutoff" do
        # The cutoff_utc is the exclusive upper bound, so vacancies created at that exact second are excluded
        vacancy = vacancy_for(ats_client, created_at: cutoff_utc, expires_at: expires_in_bst)
        expect { service }.not_to(change { vacancy.reload.expires_at })
      end

      it "does not change expires_at when created after cutoff" do
        vacancy = vacancy_for(ats_client, created_at: cutoff_utc + 1.hour, expires_at: expires_in_bst)
        expect { service }.not_to(change { vacancy.reload.expires_at })
      end
    end

    context "with a vacancy whose expires_at is outside the BST window" do
      it "does not change expires_at when expiry is after BST ends (winter/GMT)" do
        vacancy = vacancy_for(ats_client, created_at: created_in_window, expires_at: bst_end_utc + 1.day)
        expect { service }.not_to(change { vacancy.reload.expires_at })
      end
    end

    context "with a vacancy belonging to a different ATS client" do
      it "does not change expires_at" do
        vacancy = vacancy_for(other_client, created_at: created_in_window, expires_at: expires_in_bst)
        expect { service }.not_to(change { vacancy.reload.expires_at })
      end
    end

    context "when the MyNewTerm client does not exist" do
      before { ats_client.destroy }

      it "raises ActiveRecord::RecordNotFound" do
        expect { service }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
