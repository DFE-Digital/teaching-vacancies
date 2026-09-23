require "rails_helper"
require "dfe_sign_in/api"

RSpec.describe DfeSignIn::API do
  let(:dsi_url) { "https://dsi-api.contoso.com" }
  let(:dsi_password) { "dsi-signing-secret" }
  let(:first_page) { build(:dsi_users_page, users: build_list(:dsi_user, 2), page: 1, number_of_pages: 2).to_json }
  let(:second_page) { build(:dsi_users_page, users: build_list(:dsi_user, 1), page: 2, number_of_pages: 2).to_json }
  let(:json_headers) { { "Content-Type" => "application/json" } }

  around do |example|
    ClimateControl.modify(DFE_SIGN_IN_URL: dsi_url, DFE_SIGN_IN_PASSWORD: dsi_password) { example.run }
  end

  describe ".users" do
    context "when there is more than one page" do
      before do
        stub_request(:get, "#{dsi_url}/users?page=1&pageSize=275")
          .to_return(body: first_page, status: 200, headers: json_headers)
        stub_request(:get, "#{dsi_url}/users?page=2&pageSize=275")
          .to_return(body: second_page, status: 200, headers: json_headers)
      end

      it "yields every user across every page, as individual hashes rather than pages" do
        expect(described_class.users.to_a).to eq(
          JSON.parse(first_page)["users"] + JSON.parse(second_page)["users"],
        )
      end
    end

    # DSI always has users, so a successful response without them is a failure, not an empty
    # list. Yielding nothing would let a sync delete every row it holds.
    context "when a successful response has no users" do
      before do
        stub_request(:get, "#{dsi_url}/users?page=1&pageSize=275")
          .to_return(body: '{"success":false,"message":"jwt expired"}', status: 200, headers: json_headers)
      end

      it "raises with DSI's message" do
        expect { described_class.users.to_a }
          .to raise_error(DfeSignIn::API::UnexpectedResponseError, "DSI /users returned no users on page 1: jwt expired")
      end
    end

    context "when a later page has no users" do
      before do
        stub_request(:get, "#{dsi_url}/users?page=1&pageSize=275")
          .to_return(body: first_page, status: 200, headers: json_headers)
        stub_request(:get, "#{dsi_url}/users?page=2&pageSize=275")
          .to_return(body: build(:dsi_users_page, page: 2, number_of_pages: 2).to_json, status: 200, headers: json_headers)
      end

      it "raises rather than ending early" do
        expect { described_class.users.to_a }
          .to raise_error(DfeSignIn::API::UnexpectedResponseError, "DSI /users returned no users on page 2: no message")
      end
    end

    context "when a response has no page count" do
      before do
        stub_request(:get, "#{dsi_url}/users?page=1&pageSize=275")
          .to_return(body: { users: build_list(:dsi_user, 1) }.to_json, status: 200, headers: json_headers)
      end

      it "raises rather than guessing it is the last page" do
        expect { described_class.users.to_a }.to raise_error(DfeSignIn::API::UnexpectedResponseError)
      end
    end

    context "when a response isn't JSON" do
      before do
        stub_request(:get, "#{dsi_url}/users?page=1&pageSize=275")
          .to_return(body: "<html>Service unavailable</html>", status: 200, headers: { "Content-Type" => "text/html" })
      end

      it "raises" do
        expect { described_class.users.to_a }
          .to raise_error(DfeSignIn::API::UnexpectedResponseError, "DSI /users returned a response that isn't JSON on page 1")
      end
    end

    context "when the request fails" do
      before do
        stub_request(:get, "#{dsi_url}/users?page=1&pageSize=275")
          .to_return(body: '{"success":false,"message":"jwt expired"}', status: 403)
      end

      it "raises rather than yielding a partial set of users" do
        expect { described_class.users.to_a }
          .to raise_error(DfeSignIn::API::UnexpectedResponseError, "DSI /users responded with status 403 on page 1")
      end
    end

    context "when DSI is briefly unavailable" do
      before do
        stub_request(:get, "#{dsi_url}/users?page=1&pageSize=275")
          .to_return({ status: 503 }, { body: build(:dsi_users_page, users: build_list(:dsi_user, 1)).to_json, status: 200, headers: json_headers })
      end

      it "retries the request" do
        expect(described_class.users.to_a.size).to eq(1)
        expect(WebMock).to have_requested(:get, "#{dsi_url}/users?page=1&pageSize=275").times(2)
      end
    end

    it "authenticates each request with a freshly signed bearer token" do
      freeze_time do
        authenticated_request = stub_request(:get, "#{dsi_url}/users?page=1&pageSize=275")
          .with(headers: { "Authorization" => "Bearer #{expected_jwt}" })
          .to_return(body: build(:dsi_users_page, users: build_list(:dsi_user, 1)).to_json, status: 200, headers: json_headers)

        described_class.users.to_a

        expect(authenticated_request).to have_been_requested
      end
    end
  end

  # .approvers shares the paging logic with .users; only the endpoint and the user shape differ.
  describe ".approvers" do
    let(:first_approvers_page) do
      build(:dsi_users_page, users: build_list(:dsi_approver, 2), page: 1, number_of_pages: 2).to_json
    end
    let(:second_approvers_page) do
      build(:dsi_users_page, users: build_list(:dsi_approver, 1), page: 2, number_of_pages: 2).to_json
    end

    before do
      stub_request(:get, "#{dsi_url}/users/approvers?page=1&pageSize=275")
        .to_return(body: first_approvers_page, status: 200, headers: json_headers)
      stub_request(:get, "#{dsi_url}/users/approvers?page=2&pageSize=275")
        .to_return(body: second_approvers_page, status: 200, headers: json_headers)
    end

    it "yields every approver across every page of the approvers endpoint" do
      expect(described_class.approvers.to_a).to eq(
        JSON.parse(first_approvers_page)["users"] + JSON.parse(second_approvers_page)["users"],
      )
    end
  end

  def expected_jwt
    payload = { iss: "schooljobs", exp: (Time.current.getlocal + 60).to_i, aud: "signin.education.gov.uk" }
    JWT.encode(payload, dsi_password, "HS256")
  end
end
