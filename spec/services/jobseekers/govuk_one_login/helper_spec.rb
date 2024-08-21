require "rails_helper"

RSpec.describe Jobseekers::GovukOneLogin::Helper, type: :helper do
  let(:alphanumeric) { "K3u1rADFqwZQVcK8R2AzpD24o" }
  let(:uuid) { "b421e8e9-0ebb-4079-9ce7-76f63707157b" }

  before do
    allow(SecureRandom).to receive_messages(alphanumeric:, uuid:)
  end

  describe "#generate_login_params" do
    it "generates the params for the GovUk OneLogin authorize endpoint" do
      login_params = helper.generate_login_params
      expect(login_params).to include(
        redirect_uri: "http://localhost:3000/jobseekers/auth/openid_connect/callback",
        client_id: "one_login_client_id",
        response_type: "code",
        scope: "email openid",
        nonce: alphanumeric,
        state: uuid,
      )
    end
  end

  describe "#generate_logout_params" do
    it "generates the params for the GovUk OneLogin logout endpoint" do
      logout_params = helper.generate_logout_params("id_token")
      expect(logout_params).to include(
        post_logout_redirect_uri: "http://localhost:3000/jobseekers/sign_out",
        id_token_hint: "id_token",
        state: uuid,
      )
    end
  end

  describe "#govuk_one_login_uri" do
    it "generates the URI with codified params for the GovUk OneLogin login endpoint" do
      login_uri = helper.govuk_one_login_uri(:login, helper.generate_login_params)
      expect(login_uri.host).to eq "oidc.test.account.gov.uk"
      expect(login_uri.path).to eq "/authorize"
      expect(login_uri.query).to include "redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fjobseekers%2Fauth%2Fopenid_connect%2Fcallback"
      expect(login_uri.query).to include "client_id=one_login_client_id"
      expect(login_uri.query).to include "response_type=code"
      expect(login_uri.query).to include "scope=email+openid"
      expect(login_uri.query).to include "nonce=#{alphanumeric}"
      expect(login_uri.query).to include "state=#{uuid}"
    end

    it "generates the URI with codified params for the GovUk OneLogin logout endpoint" do
      logout_uri = helper.govuk_one_login_uri(:logout, helper.generate_logout_params("id_token"))
      expect(logout_uri.host).to eq "oidc.test.account.gov.uk"
      expect(logout_uri.path).to eq "/logout"
      expect(logout_uri.query).to include "post_logout_redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fjobseekers%2Fsign_out"
      expect(logout_uri.query).to include "id_token_hint=id_token"
      expect(logout_uri.query).to include "state=#{uuid}"
    end
  end
end
