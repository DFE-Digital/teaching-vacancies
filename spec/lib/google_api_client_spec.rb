require "rails_helper"
require "google_api_client"

RSpec.describe GoogleApiClient, type: :singleton do
  let(:google_api_client) { described_class.instance }
  let(:authorizer) { instance_double(Google::Auth::ServiceAccountCredentials, fetch_access_token!: true) }

  before do
    described_class.instance_variable_set(:@singleton__instance__, nil) # Needed to setup the instance with different values in each test
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(authorizer)
  end

  describe "#initialize" do
    context "when GOOGLE_API_JSON_KEY is not set" do
      before do
        allow(ENV).to receive(:fetch).with("GOOGLE_API_JSON_KEY", "").and_return("")
        allow(Rails.logger).to receive(:info).with(any_args) # Allow any other messages
      end

      it "logs a message and does not set the authorizer" do
        expect(Rails.logger).to receive(:info).with("***No GOOGLE_API_JSON_KEY set")
        google_api_client
        expect(google_api_client.authorizer).to be_nil
      end
    end

    context "when GOOGLE_API_JSON_KEY is set" do
      let(:json_key) { '{"type": "service_account"}' }

      before do
        allow(ENV).to receive(:fetch).with("GOOGLE_API_JSON_KEY", "").and_return(json_key)
      end

      it "sets the authorizer" do
        google_api_client
        expect(google_api_client.authorizer).to eq(authorizer)
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

    context "when the token is expired" do
      before do
        allow(authorizer).to receive(:expired?).and_return(true)
      end

      it "refreshes the token" do
        expect(authorizer).to receive(:fetch_access_token!)
        google_api_client.authorization
      end
    end
  end

  describe "#missing_key?" do
    context "when GOOGLE_API_JSON_KEY is empty" do
      before do
        allow(ENV).to receive(:fetch).with("GOOGLE_API_JSON_KEY", "").and_return("")
      end

      it "returns true" do
        expect(google_api_client.missing_key?).to be true
      end
    end

    context "when GOOGLE_API_JSON_KEY is not empty" do
      let(:json_key) { '{"type": "service_account"}' }

      before do
        allow(ENV).to receive(:fetch).with("GOOGLE_API_JSON_KEY", "").and_return(json_key)
      end

      it "returns false" do
        expect(google_api_client.missing_key?).to be false
      end
    end
  end
end
