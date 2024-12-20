require "rails_helper"

RSpec.describe Jobseekers::GovukOneLogin::Client do
  let(:code) { "mock_code" }
  let(:auth_service) { described_class.new(code) }
  let(:payload) { '{ "info": "auth_info" }' }
  let(:http_mock) { instance_double(Net::HTTP, :use_ssl= => true) }
  let(:response_mock) { instance_double(Net::HTTPResponse, body: payload) }

  before do
    allow(Net::HTTP).to receive(:new).with("test-onelogin-url.local", 443).and_return(http_mock)
    allow(http_mock).to receive(:request).with(request_mock).and_return(response_mock)
  end

  describe "#tokens" do
    subject(:result) { auth_service.tokens }

    let(:request_mock) { instance_double(Net::HTTP::Post, set_form_data: true) }

    before do
      allow(Rails.application.config).to receive(:govuk_one_login_private_key).and_return("private_key")
      allow(OpenSSL::PKey::RSA).to receive(:new).with("private_key").and_return(instance_double(OpenSSL::PKey::RSA))
      allow(JWT).to receive(:encode).and_return("jwt_assertion")
      allow(Net::HTTP::Post).to receive(:new).and_return(request_mock)
    end

    it "uses the correct JWT assertion" do
      allow(SecureRandom).to receive(:uuid).and_return("b421e8e9-0ebb-4079-9ce7-76f63707157b")
      allow(OpenSSL::PKey::RSA).to receive(:new).and_return("private_key")
      freeze_time do
        expected_jwt_payload = { aud: "https://test-onelogin-url.local/token",
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
        redirect_uri: "http://localhost:3000/jobseekers/auth/govuk_one_login/callback",
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

    context "when there is an exception" do
      before { allow(http_mock).to receive(:request).and_raise(StandardError, "got an error!") }

      it "raises a GovukOneLogin exception" do
        expect { result }.to raise_error(Jobseekers::GovukOneLogin::Errors::ClientRequestError,
                                         "GovukOneLogin.tokens: got an error!")
      end
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

    context "when there is an exception" do
      before { allow(http_mock).to receive(:request).and_raise(StandardError, "got an error!") }

      it "raises a GovukOneLogin exception" do
        expect { result }.to raise_error(Jobseekers::GovukOneLogin::Errors::ClientRequestError,
                                         "GovukOneLogin.user_info: got an error!")
      end
    end
  end
end
