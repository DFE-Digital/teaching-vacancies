require "rails_helper"

RSpec.describe DSIClient do
  subject(:client) do
    # See AuthHelpers#stub_authorisation_step for UUIDs
    described_class.new(
      organisation_id: "939eac36-0777-48c2-9c2c-b87c948a9ee0",
      user_id: user_id,
    )
  end

  let(:user_id) { "161d1f6a-44f1-4a1a-940d-d1088c439da7" }

  describe "#roles" do
    before do
      stub_authorisation_step
    end

    it "returns the user's roles" do
      expect(client.role_ids).to eq(["test-role-id"])
    end

    context "when the response is a 404" do
      before { stub_authorisation_step_with_not_found }

      it "raises an error" do
        expect { client.role_ids }.to raise_error(described_class::RequestInvalid)
      end
    end

    context "when the external response status is 500" do
      before { stub_authorisation_step_with_external_error }

      it "raises an error" do
        expect { client.role_ids }.to raise_error(described_class::RequestFailed)
      end
    end
  end
end
