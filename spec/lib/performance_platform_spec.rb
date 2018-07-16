require 'rails_helper'
require 'performance_platform'

RSpec.describe PerformancePlatform::TransactionsByChannel do
  context 'when no TOKEN Is set' do
    it 'aborts execution' do
      expect do
        PerformancePlatform::TransactionsByChannel.new(nil)
      end.to raise_error(SystemExit, 'No token set. Note that this task should only be executed in production.')
    end
  end

  context 'when a TOKEN is set' do
    it 'setups the correct headers' do
      performance_platform = PerformancePlatform::TransactionsByChannel.new('some-token')
      expect(performance_platform.headers).to include('Authorization' => 'Bearer some-token')
    end

    it 'posts publication data  to the Performance Platform' do
      now = Time.zone.now
      expect(Time).to receive_message_chain(:zone, :now).and_return(now)

      endpoint = 'https://www.performance.service.gov.uk/data/teaching-jobs-job-listings/transactions-by-channel'

      headers = { 'Authorization' => 'Bearer some-token',
                  'Content-Type' => 'application/json' }

      sample_data = {
        _timestamp: now.utc.iso8601,
        service: 'teaching_jobs_listings',
        channel: 'digital',
        count: 2,
        dataType: 'transactions-by-channel',
        period: 'day'
      }.to_json

      expect(HTTParty).to receive(:post).with(endpoint,
                                              body: sample_data,
                                              headers: headers)

      performance_platform = PerformancePlatform::TransactionsByChannel.new('some-token')
      performance_platform.submit_transactions(2)
    end
  end
end
