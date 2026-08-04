class ApplicationJob < ActiveJob::Base
  # Order matters: `rescue_from` handlers are matched last-registered-first, and
  # `ActiveJob::DeserializationError` is a `StandardError`. The specific
  # `discard_on` must come after the catch-all `retry_on` so that jobs whose
  # arguments no longer exist are discarded rather than retried ten times.
  retry_on StandardError, attempts: 10
  discard_on ActiveJob::DeserializationError
end
