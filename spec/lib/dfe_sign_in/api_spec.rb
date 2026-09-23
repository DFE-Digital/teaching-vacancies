require "rails_helper"
require "dfe_sign_in/api"

RSpec.describe DfeSignIn::API do
  let(:first_page) { build(:dsi_users_page, users: build_list(:dsi_user, 2), page: 1, number_of_pages: 2).to_json }
  let(:second_page) { build(:dsi_users_page, users: build_list(:dsi_user, 1), page: 2, number_of_pages: 2).to_json }
  let(:json_headers) { { "Content-Type" => "application/json" } }

  describe ".users" do
    it "returns an Enumerator without making any HTTP request" do
      enumerator = described_class.users

      expect(enumerator).to be_a(Enumerator)
      expect(WebMock).not_to have_requested(:get, /#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/)
    end

    context "when there is more than one page" do
      before do
        stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users?page=1&pageSize=275")
          .to_return(body: first_page, status: 200, headers: json_headers)
        stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users?page=2&pageSize=275")
          .to_return(body: second_page, status: 200, headers: json_headers)
      end

      it "yields every user across every page, as individual hashes rather than pages" do
        # This is the actual contract change: callers loop over users, not pages. Getting
        # this wrong (yielding arrays of pages instead of user hashes) is the most likely
        # mistake, so it's asserted directly rather than just checking a count.
        expect(described_class.users.to_a).to eq(
          JSON.parse(first_page)["users"] + JSON.parse(second_page)["users"],
        )
      end

      it "stops after the last page and does not request a page beyond numberOfPages" do
        described_class.users.to_a

        expect(WebMock).not_to have_requested(:get, /page=3/)
      end
    end

    context "when the source has no users at all" do
      let(:empty) { build(:dsi_users_page).to_json }

      before do
        stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users?page=1&pageSize=275")
          .to_return(body: empty, status: 200, headers: json_headers)
      end

      it "yields nothing, without raising" do
        expect(described_class.users.to_a).to eq([])
      end
    end

    context "when the response is a 403" do
      before do
        stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users?page=1&pageSize=275")
          .to_return(body: '{"success":false,"message":"jwt expired"}', status: 403)
      end

      it "raises when the enumerator is iterated" do
        expect { described_class.users.to_a }.to raise_error(DfeSignIn::API::ForbiddenRequestError)
      end
    end

    context "when the response is a 500" do
      before do
        stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users?page=1&pageSize=275")
          .to_return(status: 500)
      end

      it "raises when the enumerator is iterated" do
        expect { described_class.users.to_a }.to raise_error(DfeSignIn::API::ExternalServerError)
      end
    end

    it "authenticates each request with a freshly signed bearer token" do
      # Kept from the current Request spec: losing the auth header silently is the failure
      # mode that would only show up as a 403 in production, worth pinning here.
      freeze_time do
        authenticated_request = stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users?page=1&pageSize=275")
          .with(headers: { "Authorization" => "Bearer #{expected_jwt}" })
          .to_return(body: first_page, status: 200, headers: json_headers)
        # first_page reports numberOfPages: 2, so the enumerator goes on to
        # request page 2 too — stubbed here with no header assertion, since the assertion
        # above already covers what this example is about.
        stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users?page=2&pageSize=275")
          .to_return(body: second_page, status: 200, headers: json_headers)

        described_class.users.to_a

        expect(authenticated_request).to have_been_requested
      end
    end
  end

  # .approvers should be the same case as users, just a different endpoint and user shape. The two are tested side by side to make it obvious that the only difference is the endpoint, not the paging logic.
  describe ".approvers" do
    let(:first_approvers_page) do
      build(:dsi_users_page, users: build_list(:dsi_approver, 2), page: 1, number_of_pages: 2).to_json
    end
    let(:second_approvers_page) do
      build(:dsi_users_page, users: build_list(:dsi_approver, 1), page: 2, number_of_pages: 2).to_json
    end

    it "requests the approvers endpoint with the approvers page size" do
      stub = stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users/approvers?page=1&pageSize=275")
        .to_return(body: first_approvers_page, status: 200, headers: json_headers)
      # first_approvers_page reports numberOfPages: 2, so the enumerator goes on
      # to request page 2 too.
      stub_request(:get, "#{ENV.fetch('DFE_SIGN_IN_URL', nil)}/users/approvers?page=2&pageSize=275")
        .to_return(body: second_approvers_page, status: 200, headers: json_headers)

      described_class.approvers.to_a

      expect(stub).to have_been_requested
    end
  end

  def expected_jwt
    payload = { iss: "schooljobs", exp: (Time.current.getlocal + 60).to_i, aud: "signin.education.gov.uk" }
    JWT.encode(payload, ENV.fetch("DFE_SIGN_IN_PASSWORD", nil), "HS256")
  end
end
