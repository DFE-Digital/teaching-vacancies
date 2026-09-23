require "rails_helper"
require "dfe_sign_in/user_rows"

RSpec.describe DfeSignIn::UserRows do
  describe "#la_code" do
    # The users and approvers endpoints capitalise the same fields differently.
    context "with a /users-shaped organisation (PascalCase keys)" do
      it "returns the establishment number when the organisation is a local authority" do
        user = build(:dsi_user, :local_authority, establishment_number: "800")

        expect(described_class.new(user).la_code).to eq("800")
      end

      it "returns nil when the organisation is not a local authority" do
        user = build(:dsi_user, establishment_number: "800")

        expect(described_class.new(user).la_code).to be_nil
      end
    end

    context "with a /users/approvers-shaped organisation (camelCase keys)" do
      it "returns the establishment number when the organisation is a local authority" do
        approver = build(:dsi_approver, :local_authority, establishment_number: "800")

        expect(described_class.new(approver).la_code).to eq("800")
      end
    end

    it "raises when the organisation is missing, as the user can't be tied to a publisher" do
      expect { described_class.new(build(:dsi_user).except("organisation")).la_code }.to raise_error(KeyError)
    end
  end

  describe "#user_row" do
    let(:dsi_user) { build(:dsi_user, user_id: "user-1", role_name: "End user", school_urn: "100000") }

    it "maps every field BigQuery expects, keyed by the DSI-shaped input" do
      # One example asserting the full hash, rather than one `it` per field: the mapping is
      # the whole unit of behaviour, and a per-field split would hide a swapped key (e.g.
      # given/family name reversed) that a full-hash `eq` catches immediately.
      expect(described_class.new(dsi_user).user_row).to eq(
        user_id: "user-1",
        email: dsi_user["email"],
        given_name: dsi_user["givenName"],
        family_name: dsi_user["familyName"],
        role: "End user",
        school_urn: "100000",
        trust_uid: nil,
        la_code: nil,
        approval_datetime: dsi_user["approvedAt"],
        update_datetime: dsi_user["updatedAt"],
      )
    end
  end

  describe "#approver_row" do
    let(:dsi_approver) { build(:dsi_approver, :trust, user_id: "user-2", trust_uid: "555") }

    # Approvers have no approval_datetime/update_datetime and an extra role_id — asserting
    # the full hash here is what pins that shape difference from #user_row.
    it "maps the approver shape, which has no timestamps and an extra role_id" do
      expect(described_class.new(dsi_approver).approver_row).to eq(
        user_id: "user-2",
        email: dsi_approver["email"],
        given_name: dsi_approver["givenName"],
        family_name: dsi_approver["familyName"],
        role_id: "approver",
        role_name: "Approver",
        school_urn: nil,
        trust_uid: "555",
        la_code: nil,
      )
    end
  end
end
