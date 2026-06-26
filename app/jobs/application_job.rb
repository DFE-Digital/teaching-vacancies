class ApplicationJob < ActiveJob::Base
  discard_on ActiveJob::DeserializationError
  retry_on StandardError, attempts: 10
end
