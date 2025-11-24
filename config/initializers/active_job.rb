# Controls whether Active Job's `#perform_later` and similar methods automatically defer
# the job queuing to after the current Active Record transaction is committed.
# Moved here in Rails 8.0 as global setting was deprecated.
# Needed here to cover sending emails inside a transaction (which inherits from ActiveJob::Base)
# but also probably useful for the Notification gem which might have similar issues
Rails.application.config.after_initialize do
  ActiveJob::Base.enqueue_after_transaction_commit = true
end
