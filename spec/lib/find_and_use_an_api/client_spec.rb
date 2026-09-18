require "rails_helper"

RSpec.describe FindAndUseAnApi::Client do
  let(:base_url) { "https://fauapi.example.com" }
  let(:token) { "fake-fauapi-automation-token" }
  let(:manifest) { { name: "teaching-vacancies-ats-api", majorVersion: "v1" } }

  around { |example| with_env("FAUAPI_BASE_URL" => base_url, "FAUAPI_API_KEY" => token) { example.run } }

  describe ".import" do
    it "posts the manifest as JSON and returns the parsed body" do
      stub = stub_request(:post, "#{base_url}/api/tasks/apis/import")
        .with(body: manifest.to_json,
              headers: { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json" })
        .to_return(status: 200, body: { id: "abc123" }.to_json)

      expect(described_class.import(manifest)).to eq({ "id" => "abc123" })
      expect(stub).to have_been_requested
    end
  end

  describe ".list_apis" do
    it "returns the parsed catalogue entries" do
      stub_request(:get, "#{base_url}/api/tasks/apis")
        .with(headers: { "Authorization" => "Bearer #{token}" })
        .to_return(status: 200, body: [{ id: "abc123", name: "teaching-vacancies-ats-api" }].to_json)

      expect(described_class.list_apis).to eq([{ "id" => "abc123", "name" => "teaching-vacancies-ats-api" }])
    end
  end

  describe ".publish" do
    it "puts to the publish endpoint for the given id" do
      stub = stub_request(:put, "#{base_url}/api/tasks/apis/abc123/publish")
        .with(headers: { "Authorization" => "Bearer #{token}" })
        .to_return(status: 204, body: "")

      expect(described_class.publish("abc123")).to eq({})
      expect(stub).to have_been_requested
    end
  end

  describe "error handling" do
    it "raises an HttpError including the status and body" do
      stub_request(:post, "#{base_url}/api/tasks/apis/import")
        .to_return(status: 422, body: "majorVersion is required")

      expect { described_class.import(manifest) }
        .to raise_error(described_class::HttpError, /422.*majorVersion is required/)
    end

    it "does not leak the automation token in the error message" do
      stub_request(:get, "#{base_url}/api/tasks/apis").to_return(status: 401, body: "unauthorized")

      expect { described_class.list_apis }.to raise_error(described_class::HttpError) { |error|
        expect(error.message).not_to include(token)
      }
    end
  end
end
