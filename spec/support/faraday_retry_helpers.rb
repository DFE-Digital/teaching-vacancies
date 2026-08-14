# Faraday::Retry::Middleware sleeps for real between retries. Skip that in specs so
# tests that exercise the retry behaviour (deliberately or incidentally, via WebMock
# stubs returning a retryable status/error) stay fast without changing retry
# counts/outcomes.
module SkipFaradayRetrySleep
  def sleep(*) = nil
end

Faraday::Retry::Middleware.prepend(SkipFaradayRetrySleep)
