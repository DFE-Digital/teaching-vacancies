# Shared Faraday connection used for all outbound HTTP requests to third-party
# APIs/feeds, configured to automatically retry ephemeral failures.
#
# Retries are limited to 3 attempts with an exponential backoff (0.5s, 1s, 2s,
# plus a little jitter) so a flaky endpoint doesn't hold up the job/request for
# too long, while still smoothing over the kind of transient blips (timeouts,
# connection resets, 502/503/504) that would otherwise crash the whole import.
class HttpClient
  DEFAULT_RETRY_OPTIONS = {
    max: 3,
    interval: 0.5,
    backoff_factor: 2,
    interval_randomness: 0.5,
    max_interval: 5,
    methods: %i[get],
    retry_statuses: [429, 500, 502, 503, 504],
    exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed],
  }.freeze

  class << self
    def connection(retry_options: {}, **faraday_options)
      Faraday.new(**faraday_options) do |conn|
        conn.request :retry, DEFAULT_RETRY_OPTIONS.merge(retry_options)
        conn.adapter Faraday.default_adapter

        yield conn if block_given?
      end
    end
  end
end
