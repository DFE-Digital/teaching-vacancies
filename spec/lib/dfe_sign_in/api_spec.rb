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

  describe "retrying a failed page" do
    let(:fixture_filename) { "users" }

    # Retrying at the job level would restart pagination from page one, so a transient
    # failure has to be absorbed here instead.
    before { stub_const("DfeSignIn::API::PaginatedUsers::RETRY_WAIT_SECONDS", 0) }

    it "retries the page and carries on when the failure is transient" do
      stub_responses(DfeSignIn::API::Request::ExternalServerError, stubbed_response, stubbed_response)

      expect(subject.dsi_users.to_a).to eq [JSON.parse(response_file(1))["users"],
                                            JSON.parse(response_file(2))["users"]]
    end

    it "gives up once the page has been attempted the maximum number of times" do
      stub_responses(*Array.new(DfeSignIn::API::PaginatedUsers::PAGE_ATTEMPTS, DfeSignIn::API::Request::ExternalServerError))

      expect { subject.dsi_users }.to raise_error(DfeSignIn::API::Request::ExternalServerError)
    end

    it "does not retry errors that will not resolve themselves" do
      stub_responses(DfeSignIn::API::Request::ForbiddenRequestError, stubbed_response)

      expect { subject.dsi_users }.to raise_error(DfeSignIn::API::Request::ForbiddenRequestError)
      expect(DfeSignIn::API::Response).to have_received(:new).once
    end

    # Each element is either an exception class to raise or a response to return, consumed
    # one per call to `DfeSignIn::API::Response.new`.
    def stub_responses(*outcomes)
      allow(DfeSignIn::API::Response).to receive(:new) do
        outcome = outcomes.shift
        raise outcome if outcome.is_a?(Class)

        outcome
      end
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
