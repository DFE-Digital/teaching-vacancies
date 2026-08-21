require "rails_helper"

RSpec.describe Gias::Data do
  subject(:data) { described_class.new(type) }

  let(:type) { "allgroupsdata" }
  let(:csv_url) { "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/#{type}#{Time.current.strftime('%Y%m%d')}.csv" }
  let(:csv_body) { "URN,EstablishmentName\n100000,Test School\n" }

  before { freeze_time }

  describe "#each" do
    it "downloads and yields the parsed CSV rows" do
      stub_request(:get, csv_url).to_return(status: 200, body: csv_body)

      rows = data.to_a

      expect(rows.size).to eq(1)
      expect(rows.first["URN"]).to eq("100000")
    end

    it "sends a User-Agent header" do
      stub = stub_request(:get, csv_url).with(headers: { "User-Agent" => "teaching-vacancies" }).to_return(status: 200, body: csv_body)

      data.to_a

      expect(stub).to have_been_requested
    end

    it "raises when the response is not successful" do
      stub_request(:get, csv_url).to_return(status: 404, body: "not found")

      expect { data.to_a }.to raise_error(/Could not download file #{Regexp.escape(csv_url)} from GIAS: 404/)
    end

    it "retries after a connection failure" do
      stub_request(:get, csv_url)
        .to_raise(Faraday::ConnectionFailed)
        .then
        .to_return(status: 200, body: csv_body)

      rows = data.to_a

      expect(rows.size).to eq(1)
      expect(rows.first["URN"]).to eq("100000")
    end

    it "retries a retryable status and eventually downloads successfully" do
      stub_request(:get, csv_url).to_return({ status: 503 }, { status: 200, body: csv_body })

      rows = data.to_a

      expect(rows.size).to eq(1)
      expect(rows.first["URN"]).to eq("100000")
      expect(WebMock).to have_requested(:get, csv_url).times(2)
    end
  end
end
