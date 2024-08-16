require "rails_helper"
require "gov_uk_one_login_client"

RSpec.describe GovUkOneLoginClient do
  let(:code) { "mock_code" }
  let(:auth_service) { described_class.new(code) }
  let(:payload) { '{ "info": "auth_info" }' }
  let(:http_mock) { instance_double(Net::HTTP, :use_ssl= => true) }
  let(:response_mock) { instance_double(Net::HTTPResponse, body: payload) }

  before do
    allow(Net::HTTP).to receive(:new).with("oidc.test.account.gov.uk", 443).and_return(http_mock)
    allow(http_mock).to receive(:request).with(request_mock).and_return(response_mock)
  end

  RSpec.shared_examples "error management" do
    context "when there is an exception" do
      before { allow(http_mock).to receive(:request).and_raise(StandardError, "got an error!") }

      it "returns an empty hash" do
        expect(result).to(eq({}))
      end

      it "logs the error" do
        allow(Rails.logger).to receive(:error)
        result
        expect(Rails.logger).to have_received(:error).with(expected_log_message)
      end
    end
  end

  describe "#tokens" do
    subject(:result) { auth_service.tokens }

    let(:request_mock) { instance_double(Net::HTTP::Post, set_form_data: true) }

    before do
      allow(JWT).to receive(:encode).and_return("jwt_assertion")
      allow(Net::HTTP::Post).to receive(:new).and_return(request_mock)
    end

    it "uses the correct JWT assertion" do
      allow(SecureRandom).to receive(:uuid).and_return("b421e8e9-0ebb-4079-9ce7-76f63707157b")
      allow(OpenSSL::PKey::RSA).to receive(:new).and_return("private_key")
      freeze_time do
        expected_jwt_payload = { aud: "https://oidc.test.account.gov.uk/token",
                                 iss: "one_login_client_id",
                                 sub: "one_login_client_id",
                                 exp: Time.zone.now.to_i + 300,
                                 jti: "b421e8e9-0ebb-4079-9ce7-76f63707157b",
                                 iat: Time.zone.now.to_i }
        result
        expect(JWT).to have_received(:encode).with(expected_jwt_payload, "private_key", "RS256")
      end
    end

    it "sets the needed form data for the request" do
      result
      expect(request_mock).to have_received(:set_form_data).with(
        grant_type: "authorization_code",
        code: code,
        redirect_uri: "https://localhost:3000/users/auth/openid_connect/callback",
        client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
        client_assertion: "jwt_assertion",
      )
    end

    it "triggers a Post request to the token endpoint" do
      result
      expect(Net::HTTP::Post).to have_received(:new).with("/token", { "Content-Type" => "application/x-www-form-urlencoded" })
      expect(http_mock).to have_received(:request).with(request_mock)
    end

    it "returns the parsed response body" do
      expect(result).to eq({ "info" => "auth_info" })
    end

    include_examples "error management" do
      let(:expected_log_message) { "GovUkOneLogin.tokens: got an error!" }
    end
  end

  describe "#user_info" do
    subject(:result) { auth_service.user_info("access_token") }

    let(:request_mock) { instance_double(Net::HTTP::Get) }

    before do
      allow(Net::HTTP::Get).to receive(:new).and_return(request_mock)
    end

    it "triggers a Get request to the user info endpoint" do
      result
      expect(Net::HTTP::Get).to have_received(:new).with("/userinfo", { "Authorization" => "Bearer access_token" })
      expect(http_mock).to have_received(:request).with(request_mock)
    end

    it "returns the parsed response body" do
      expect(result).to eq({ "info" => "auth_info" })
    end

    include_examples "error management" do
      let(:expected_log_message) { "GovUkOneLogin.user_info: got an error!" }
    end
    context "when there is an exception" do
      before { allow(http_mock).to receive(:request).and_raise(StandardError, "got an error!") }

      it "returns an empty hash" do
        expect(result).to(eq({}))
      end

      it "logs the error" do
        allow(Rails.logger).to receive(:error)
        result
        expect(Rails.logger).to have_received(:error).with("GovUkOneLogin.user_info: got an error!")
      end
    end
  end
end
