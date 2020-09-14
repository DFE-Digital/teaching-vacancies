module PerformancePlatform
  PP_DOMAIN = 'https://www.performance.service.gov.uk'.freeze

  class Base
    attr_reader :headers

    def initialize(token = nil)
      return unless Rails.env.production?
      raise ArgumentError, 'No token set. Note that this task should only be executed in production.' if token.nil?

      @headers = { 'Authorization' => "Bearer #{token}",
                   'Content-Type' => 'application/json' }
    end

    def submit(data, timestamp = Time.zone.now.iso8601, period = 'day')
      HTTParty.post("#{PP_DOMAIN}#{transaction_endpoint}",
                    body: data_map(timestamp, period, data),
                    headers: headers)
    end
  end

  class TransactionsByChannel < Base
  private

    def transaction_endpoint
      '/data/teaching-jobs-job-listings/transactions-by-channel'
    end

    def data_map(timestamp, period, count)
      { _timestamp: timestamp,
        service: 'teaching_jobs_listings',
        channel: 'digital',
        count: count,
        dataType: 'transactions-by-channel',
        period: period }.to_json
    end
  end
end
