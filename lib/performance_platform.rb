module PerformancePlatform
  PP_DOMAIN = 'https://www.performance.service.gov.uk'.freeze

  class TransactionsByChannel
    attr_reader :headers

    def initialize(token = nil)
      token || abort('No token set. Note that this task should only be executed in production.')
      @headers = { 'Authorization' => "Bearer #{token}",
                   'Content-Type' => 'application/json' }
      self
    end

    def submit_transactions(count, timestamp = Time.zone.now.utc.iso8601, period = 'day')
      HTTParty.post("#{PP_DOMAIN}#{transaction_endpoint}",
                    body: data(timestamp, period, count),
                    headers: headers)
    end

    private

    def transaction_endpoint
      '/data/teaching-jobs-job-listings/transactions-by-channel'
    end

    def data(timestamp, period, count)
      { _timestamp: timestamp,
        service: 'teaching_jobs_listings',
        channel: 'digital',
        count: count,
        dataType: 'transactions-by-channel',
        period: period }.to_json
    end
  end
end
