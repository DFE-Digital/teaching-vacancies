require "rails_helper"
require "dfe_sign_in/api"

RSpec.describe DfeSignIn::API do
  let(:stubbed_request) { instance_double(DfeSignIn::API::Request) }
  let(:stubbed_response) { instance_double(DfeSignIn::API::Response, number_of_pages: 2) }

  before do
    allow(stubbed_response).to receive(:users).and_return(JSON.parse(response_file(1))["users"],
                                                          JSON.parse(response_file(2))["users"])
    allow(DfeSignIn::API::Request).to receive(:new).and_return(stubbed_request)
    allow(DfeSignIn::API::Response).to receive(:new).with(stubbed_request).and_return(stubbed_response)
  end

  subject { extend(described_class) }

  describe "#dsi_users" do
    let(:fixture_filename) { "users" }

    it "returns a lazy enumerator of users" do
      expect(subject.dsi_users).to be_a(Enumerator::Lazy)
    end

    it "the enumerated collection contains all users from the API as pages" do
      expect(subject.dsi_users.to_a).to eq [JSON.parse(response_file(1))["users"],
                                            JSON.parse(response_file(2))["users"]]
    end
  end

  describe "#dsi_approvers" do
    let(:fixture_filename) { "approvers" }

    it "returns a lazy enumerator of approvers" do
      expect(subject.dsi_approvers).to be_a(Enumerator::Lazy)
    end

    it "the enumerated collection contains all approvers from the API as pages" do
      expect(subject.dsi_approvers.to_a).to eq [JSON.parse(response_file(1))["users"],
                                                JSON.parse(response_file(2))["users"]]
    end
  end

  def response_file(page)
    File.read(Rails.root.join(
                "spec",
                "fixtures",
                "dfe_sign_in_service_#{fixture_filename}_response_page_#{page}.json",
              ))
  end
end
