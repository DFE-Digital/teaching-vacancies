require "rails_helper"
require "google_indexing"

RSpec.describe GoogleIndexing do
  let(:url) { "https://google.com" }
  let(:mock_request) { instance_double(Google::Apis::IndexingV3::UrlNotification) }
  let(:authorization) { instance_double(Google::Auth::ServiceAccountCredentials, fetch_access_token!: true) }
  let(:google_service) do
    instance_double(Google::Apis::IndexingV3::IndexingService,
                    "authorization=": authorization,
                    publish_url_notification: true)
  end
  let(:service) { GoogleIndexing.new(url) }

  before do
    allow(GoogleApiClient).to receive(:instance).and_return(google_api_client)
    allow(Google::Apis::IndexingV3::UrlNotification).to receive(:new).and_return(mock_request)
    allow(Google::Apis::IndexingV3::IndexingService).to receive(:new).and_return(google_service)
  end

  context "Successful requests" do
    let(:google_api_client) { instance_double(GoogleApiClient, missing_key?: false, authorization: authorization) }

    context "Requesting a url index update" do
      it "sets up the indexing service and its authorization" do
        expect(Google::Apis::IndexingV3::IndexingService).to receive(:new).and_return(google_service)
        expect(google_service).to receive(:authorization=).with(authorization).and_return(authorization)

        service.update
      end

      it "notifies the indexing API" do
        expect(Google::Apis::IndexingV3::UrlNotification)
          .to receive(:new)
          .with(url: url, type: GoogleIndexing::ACTIONS[:update])
          .and_return(mock_request)
        expect(google_service).to receive(:publish_url_notification).with(mock_request)

        service.update
      end
    end

    context "Requesting a url index removal" do
      it "sets up the indexing service and its authorization" do
        expect(Google::Apis::IndexingV3::IndexingService).to receive(:new).and_return(google_service)
        expect(google_service).to receive(:authorization=).with(authorization).and_return(authorization)

        service.remove
      end

      it "notifies the indexing API" do
        expect(Google::Apis::IndexingV3::UrlNotification)
          .to receive(:new)
          .with(url: url, type: GoogleIndexing::ACTIONS[:remove])
          .and_return(mock_request)
        expect(google_service).to receive(:publish_url_notification).with(mock_request)

        service.remove
      end
    end
  end

  context "When the Google API client has is missing its key" do
    let(:google_api_client) { instance_double(GoogleApiClient, missing_key?: true, authorization: nil) }

    it "logs an error and aborts execution" do
      expect(GoogleIndexing::API::IndexingService).not_to receive(:new)
      service
    end
  end
end
