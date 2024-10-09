require "rails_helper"

RSpec.describe Jobseekers::GovukOneLogin::UserFromAuthResponse do
  let(:user_session) { { govuk_one_login_state: "state_stub", govuk_one_login_nonce: "nonce_stub" } }
  let(:auth_response) { { "code" => "code_stub", "state" => "state_stub" } }

  describe ".call" do
    it "initializes a new instance and calls it" do
      user_from_auth_response = instance_double(Jobseekers::GovukOneLogin::UserFromAuthResponse)
      allow(Jobseekers::GovukOneLogin::UserFromAuthResponse).to receive(:new).and_return(user_from_auth_response)
      allow(user_from_auth_response).to receive(:call)

      described_class.call(auth_response, user_session)

      expect(Jobseekers::GovukOneLogin::UserFromAuthResponse).to have_received(:new).with(auth_response, user_session)
      expect(user_from_auth_response).to have_received(:call)
    end
  end

  describe "#call" do
    let(:tokens_response) { { "access_token" => "access_token_stub", "id_token" => "id_token_stub" } }
    let(:decoded_id_token) do
      [{ "sub" => "sub_stub",
         "nonce" => "nonce_stub",
         "iss" => "#{Rails.application.config.govuk_one_login_base_url}/",
         "aud" => Rails.application.config.govuk_one_login_client_id }]
    end
    let(:user_info_response) { { "email" => "user@example.com", "sub" => "sub_stub" } }
    let(:client) do
      instance_double(Jobseekers::GovukOneLogin::Client, tokens: tokens_response,
                                                         decode_id_token: decoded_id_token,
                                                         user_info: user_info_response)
    end

    before do
      allow(Jobseekers::GovukOneLogin::Client).to receive(:new).with(auth_response["code"]).and_return(client)
    end

    describe "validates the current user session" do
      it "raises an error if given user session does not contain the one login state" do
        user_session = { govuk_one_login_nonce: "nonce" }
        expect { described_class.new(auth_response, user_session).call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::SessionKeyError,
                          "Missing key: 'govuk_one_login_state' is not set in the user session")
      end

      it "raises an error if given user session does not contain the one login nonce" do
        user_session = { govuk_one_login_state: "state_stub" }
        expect { described_class.new(auth_response, user_session).call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::SessionKeyError,
                          "Missing key: 'govuk_one_login_nonce' is not set in the user session")
      end
    end

    describe "validates the authentication response" do
      it "raises an error if the auth response contains an error" do
        auth_response = { "error" => "error", "error_description" => "error description" }
        expect { described_class.new(auth_response, user_session).call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::AuthenticationError, "error: error description")
      end

      it "raises an error if the auth response does not contain a code" do
        auth_response = { "state" => "state_stub" }
        expect { described_class.new(auth_response, user_session).call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::AuthenticationError, "Missing: 'code' is missing")
      end

      it "raises an error if the auth response does not contain a state" do
        auth_response = { "code" => "code_stub" }
        expect { described_class.new(auth_response, user_session).call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::AuthenticationError, "Missing: 'state' is missing")
      end

      it "raises an error if the auth response state does not match the user session state" do
        auth_response = { "code" => "code_stub", "state" => "invalid_state" }
        expect { described_class.new(auth_response, user_session).call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::AuthenticationError,
                          "Invalid: 'state' doesn't match the user session 'state' value")
      end
    end

    describe "requests a token from Govuk One Login" do
      subject(:user_from_auth_response) { described_class.new(auth_response, user_session) }

      it "asks the client for the tokens" do
        described_class.new(auth_response, user_session).call
        expect(client).to have_received(:tokens)
      end

      it "raises an error if the tokens response is empty" do
        allow(client).to receive(:tokens).and_return({})
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::TokensError, "Missing: The tokens response is empty")
      end

      it "raises an error if the tokens response contains an error" do
        allow(client).to receive(:tokens).and_return("error" => "error", "error_description" => "error description")
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::TokensError, "error: error description")
      end

      it "raises an error if the tokens response does not contain an access token" do
        allow(client).to receive(:tokens).and_return("id_token" => "id_token_stub")
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::TokensError, "Missing: 'access_token' is missing")
      end

      it "raises an error if the tokens response does not contain an id token" do
        allow(client).to receive(:tokens).and_return("access_token" => "access_token_stub")
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::TokensError, "Missing: 'id_token' is missing")
      end
    end

    describe "validates the decoded id token" do
      subject(:user_from_auth_response) { described_class.new(auth_response, user_session) }

      it "raises an error if the id token is empty" do
        allow(client).to receive(:decode_id_token).and_return([])
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::IdTokenError, "Missing: The id token is empty")
      end

      it "raises an error if the id token nonce does not match the user session nonce" do
        decoded_id_token[0]["nonce"] = "invalid_nonce"
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::IdTokenError,
                          "Invalid: 'nonce' doesn't match the user session 'nonce' value")
      end

      it "raises an error if the id token iss does not match the configured value" do
        decoded_id_token[0]["iss"] = "invalid_iss"
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::IdTokenError,
                          "Invalid: 'iss' doesn't match the value configured in our service")
      end

      it "raises an error if the id token aud does not match the client id" do
        decoded_id_token[0]["aud"] = "invalid_aud"
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::IdTokenError,
                          "Invalid: 'aud' doesn't match our client id")
      end
    end

    describe "requests user info from Govuk One Login" do
      subject(:user_from_auth_response) { described_class.new(auth_response, user_session) }

      it "asks the client for the user info" do
        user_from_auth_response.call
        expect(client).to have_received(:user_info).with("access_token_stub")
      end

      it "raises an error if the user info response is empty" do
        allow(client).to receive(:user_info).and_return({})
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::UserInfoError, "Missing: The user info is empty")
      end

      it "raises an error if the user info response contains an error" do
        allow(client).to receive(:user_info).and_return("error" => "error", "error_description" => "error description")
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::UserInfoError, "error: error description")
      end

      it "raises an error if the user info response does not contain an email" do
        allow(client).to receive(:user_info).and_return("sub" => "sub_stub")
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::UserInfoError, "Missing: 'email' is missing")
      end

      it "raises an error if the user info response sub does not match the user id" do
        user_info_response["sub"] = "invalid_sub"
        expect { user_from_auth_response.call }
          .to raise_error(Jobseekers::GovukOneLogin::Errors::UserInfoError,
                          "Invalid: 'sub' doesn't match the user id")
      end
    end

    describe "result" do
      subject(:result) { described_class.new(auth_response, user_session).call }

      it "returns a Jobseekers::GovukOneLogin::User" do
        expect(result).to be_a(Jobseekers::GovukOneLogin::User)
      end

      it "contains the user id in Govuk One Login" do
        expect(result.id).to eq("sub_stub")
      end

      it "contains the user email" do
        expect(result.email).to eq("user@example.com")
      end

      it "contains the id token" do
        expect(result.id_token).to eq("id_token_stub")
      end
    end
  end
end
