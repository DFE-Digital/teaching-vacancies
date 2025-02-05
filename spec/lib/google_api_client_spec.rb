require "rails_helper"
require "google_api_client"

RSpec.describe GoogleApiClient, type: :singleton do
  let(:google_api_client) { described_class.instance }
  let(:authorizer) do
    instance_double(Google::Auth::ServiceAccountCredentials, fetch_access_token!: true, expired?: false)
  end

  before do
    described_class.instance_variable_set(:@singleton__instance__, nil) # Needed to setup the instance with different values in each test
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(authorizer)
  end

  describe "#initialize" do
    context "when GOOGLE_API_JSON_KEY is not set" do
      before do
        allow(ENV).to receive(:fetch).with("GOOGLE_API_JSON_KEY", "").and_return("")
        allow(Rails.logger).to receive(:info).with(any_args)
      end

      it "logs a message and does not set the authorizer" do
        expect(Rails.logger).to receive(:info).with("***No GOOGLE_API_JSON_KEY set")
        google_api_client
        expect(Google::Auth::ServiceAccountCredentials).not_to receive(:make_creds)
      end
    end

    context "when GOOGLE_API_JSON_KEY is set" do
      let(:json_key) { '{"type": "service_account"}' }

      before do
        allow(ENV).to receive(:fetch).with("GOOGLE_API_JSON_KEY", "").and_return(json_key)
      end

      it "sets the authorizer and fetches the access token" do
        allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(authorizer)
        expect(authorizer).to receive(:fetch_access_token!)
        google_api_client
      end
    end
  end

  describe "#authorization" do
    before do
      allow(google_api_client).to receive(:authorizer).and_return(authorizer)
    end

    it "returns the authorizer" do
      expect(google_api_client.authorization).to eq(authorizer)
    end

    it "returns nil when there is no authorizer" do
      allow(google_api_client).to receive(:authorizer).and_return(nil)
      expect(google_api_client.authorization).to be_nil
    end

    it "does not refresh the token for non expired authorizations" do
      allow(authorizer).to receive(:expired?).and_return(false)
      expect(authorizer).not_to receive(:fetch_access_token!)
      google_api_client.authorization
    end

    it "refreshes the token for expired authorizations" do
      allow(authorizer).to receive(:expired?).and_return(true)
      expect(authorizer).to receive(:fetch_access_token!)
      google_api_client.authorization
    end
  end
end
