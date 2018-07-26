module PerformancePlatform
  PP_DOMAIN = 'https://www.performance.service.gov.uk'.freeze

  class Base
    attr_reader :headers

    def initialize(token = nil)
      token || abort('No token set. Note that this task should only be executed in production.')
      @headers = { 'Authorization' => "Bearer #{token}",
                   'Content-Type' => 'application/json' }
      self
    end
  end

  class TransactionsByChannel < Base
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

  class UserSatisfaction < Base
    def submit(rating_counts, timestamp = Time.zone.now.utc.iso8601, period = 'day')
      HTTParty.post("#{PP_DOMAIN}#{transaction_endpoint}",
                    body: data(timestamp, period, rating_counts.values.inject(:+), rating_counts),
                    headers: headers)
    end

    private

    def transaction_endpoint
      '/data/teaching-jobs-job-listings/user-satisfaction'
    end

    def data(timestamp, period, total, rating_counts)
      data = { _timestamp: timestamp,
               rating_1: rating_counts[1],
               rating_2: rating_counts[2],
               rating_3: rating_counts[3],
               rating_4: rating_counts[4],
               rating_5: rating_counts[5],
               service: 'teaching_jobs_listings',
               total: total,
               dataType: 'user-satisfaction',
               period: period }.to_json
      data
    end
  end
end
