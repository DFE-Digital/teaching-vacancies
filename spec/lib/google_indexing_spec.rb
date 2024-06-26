require "rails_helper"
require "google_indexing"

RSpec.describe GoogleIndexing do
  let(:url) { "https://google.com" }
  let(:mock_request) { double(:mock_request) }
  let(:google_service) { double(:google_service) }
  let(:service) { GoogleIndexing.new(url) }

  context "Successful requests" do
    before(:each) do
      stub_const("GOOGLE_API_JSON_KEY", '{ "key": "value" }')
    end

    context "Requesting a url index update" do
      it "notifies the indexing API" do
        expect(Google::Apis::IndexingV3::IndexingService)
          .to receive(:new).and_return(google_service)
        expect(Google::Apis::IndexingV3::UrlNotification)
          .to receive(:new)
          .with(url: url, type: GoogleIndexing::ACTIONS[:update])
          .and_return(mock_request)
        expect(google_service).to receive(:publish_url_notification).with(mock_request)

        service.update
      end
    end

    context "Requesting a url index removal" do
      it "notifies the indexing API" do
        expect(Google::Apis::IndexingV3::IndexingService)
          .to receive(:new).and_return(google_service)
        expect(Google::Apis::IndexingV3::UrlNotification)
          .to receive(:new)
          .with(url: url, type: GoogleIndexing::ACTIONS[:remove])
          .and_return(mock_request)
        expect(google_service).to receive(:publish_url_notification).with(mock_request)

        service.remove
      end
    end
  end

  context "When no GOOGLE_API key is set" do
    it "logs an error and aborts execution" do
      stub_const("GOOGLE_API_JSON_KEY", "")
      expect(GoogleIndexing::API::IndexingService).not_to receive(:new)
      GoogleIndexing.new(url)
    end
  end
end
