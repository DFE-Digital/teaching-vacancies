require "rails_helper"

RSpec.describe Authorisation do
  subject(:authorisation) do
    described_class.new(organisation_id: "123", user_id: "456", dsi_client:)
  end

  let(:dsi_client) { instance_double("DSIClient", role_ids:) }
  let(:role_ids) { [] }
  let(:organisations) { [] }

  describe "#authorised_publisher?" do
    context "when roles include the publisher role ID" do
      let(:role_ids) { ["test-publisher-role-id"] }

      it { should be_authorised_publisher }
    end

    context "when roles do not include the publisher role ID" do
      let(:role_ids) { ["unknown-role-id"] }

      it { should_not be_authorised_publisher }
    end

    context "when there are no roles" do
      let(:role_ids) { [] }

      it { should_not be_authorised_publisher }
    end

    context "when the DSI request 404s" do
      before do
        allow(dsi_client).to receive(:role_ids)
          .and_raise(DSIClient::RequestInvalid, "404")
      end

      it { should_not be_authorised_publisher }
    end

    context "when the DSI request 500s" do
      before do
        allow(dsi_client).to receive(:role_ids)
          .and_raise(DSIClient::RequestFailed, "502")
      end

      it "raises its own error" do
        expect { subject.authorised_publisher? }.to raise_error(described_class::ExternalServerError, "502")
      end
    end
  end

  describe "#authorised_support_user?" do
    context "when roles include the support user role ID" do
      let(:role_ids) { ["test-support-user-role-id"] }

      it { should be_authorised_support_user }
    end

    context "when roles do not include the publisher role ID" do
      let(:role_ids) { ["unknown-role-id"] }

      it { should_not be_authorised_support_user }
    end

    context "when there are no roles" do
      let(:role_ids) { [] }

      it { should_not be_authorised_support_user }
    end

    context "when the DSI request 404s" do
      before do
        allow(dsi_client).to receive(:role_ids)
          .and_raise(DSIClient::RequestInvalid, "404")
      end

      it { should_not be_authorised_support_user }
    end

    context "when the DSI request 500s" do
      before do
        allow(dsi_client).to receive(:role_ids)
          .and_raise(DSIClient::RequestFailed, "502")
      end

      it "raises its own error" do
        expect { subject.authorised_support_user? }.to raise_error(described_class::ExternalServerError, "502")
      end
    end
  end

  context "when both roles are present" do
    let(:role_ids) do
      %w[
        test-publisher-role-id
        test-support-user-role-id
      ]
    end

    it "is true that the user is authorised for both roles" do
      expect(authorisation).to be_authorised_publisher
      expect(authorisation).to be_authorised_support_user
    end
  end
end
