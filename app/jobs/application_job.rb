class ApplicationJob < ActiveJob::Base
  # Order matters: `rescue_from` handlers are matched last-registered-first, and
  # `ActiveJob::DeserializationError` is a `StandardError`. The specific
  # `discard_on` must come after the catch-all `retry_on` so that jobs whose
  # arguments no longer exist are discarded rather than retried.
  #
  # The backoff is deliberately polynomial rather than the Active Job default of a flat
  # 3 seconds: attempts spaced 3 seconds apart exhaust the whole retry budget in under half
  # a minute, which is not long enough to ride out an external API being briefly
  # unavailable. Polynomially longer spreads the 8 attempts over roughly 75 minutes.
  retry_on StandardError, wait: :polynomially_longer, attempts: 8
  discard_on ActiveJob::DeserializationError
end
