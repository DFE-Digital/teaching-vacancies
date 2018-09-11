require 'rails_helper'
require 'indexing'

RSpec.describe Indexing do
  let(:url) { 'https://google.com' }
  let(:mock_request) { double(:mock_request) }
  let(:google_service) { double(:google_service) }
  let(:service) { Indexing.new(url) }

  context 'Requesting a url index update' do
    it 'notifies the indexing API' do
      expect(Google::Apis::IndexingV3::IndexingService)
        .to receive(:new).and_return(google_service)
      expect(Google::Apis::IndexingV3::UrlNotification)
        .to receive(:new)
        .with(url: url, type: Indexing::ACTIONS[:update])
        .and_return(mock_request)
      expect(google_service).to receive(:publish_url_notification).with(mock_request)

      service.update
    end
  end

  context 'Requesting a url index removal' do
    it 'notifies the indexing API' do
      expect(Google::Apis::IndexingV3::IndexingService)
        .to receive(:new).and_return(google_service)
      expect(Google::Apis::IndexingV3::UrlNotification)
        .to receive(:new)
        .with(url: url, type: Indexing::ACTIONS[:remove])
        .and_return(mock_request)
      expect(google_service).to receive(:publish_url_notification).with(mock_request)

      service.remove
    end
  end
end
