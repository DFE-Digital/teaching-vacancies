Sentry.init do |config|
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters - %i[id name])

  # Sanitize sensitive data before sending
  config.before_send = lambda do |event, _hint|
    if event.extra
      event.extra = filter.filter(event.extra)
    end

    if event.tags
      event.tags = filter.filter(event.tags)
    end

    if event.request&.data
      event.request.data = filter.filter(event.request.data)
    end

    if event.fingerprint
      event.fingerprint = filter.filter(event.fingerprint)
    end

    if event.user
      event.user = filter.filter(event.user)
    end

    if event.contexts
      event.contexts = filter.filter(event.contexts)
    end

    # Return the sanitized event object
    event
  end

  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # Modify default excluded exceptions
  # We do not want to exclude `ActiveRecord::RecordNotFound` - most of the time, this is
  # automatically called (and disregarded) by the `rescue_from` in `ApplicationController`
  # anyway, but on occasion we want to perform a query that we expect *never* to fail, and
  # send the error through to Sentry if it does fail so that we have visibility into it.
  config.excluded_exceptions -= ["ActiveRecord::RecordNotFound"]

  config.environment = Rails.application.config.app_role
  config.enabled_environments = %w[review qa staging production]
  config.release = ENV.fetch("COMMIT_SHA", nil)
end
