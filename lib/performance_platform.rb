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

    def data_map(timestamp, period, data)
      { _timestamp: timestamp,
        service: 'teaching_jobs_listings',
        channel: 'digital',
        count: data,
        dataType: 'transactions-by-channel',
        period: period }.to_json
    end
  end

  class UserSatisfaction < Base
    private

    def transaction_endpoint
      '/data/teaching-jobs-job-listings/user-satisfaction'
    end

    def data_map(timestamp, period, data)
      { _timestamp: timestamp,
        rating_1: data[1],
        rating_2: data[2],
        rating_3: data[3],
        rating_4: data[4],
        rating_5: data[5],
        service: 'teaching_jobs_listings',
        total: data.values.inject(:+),
        dataType: 'user-satisfaction',
        period: period }.to_json
    end
  end
end
