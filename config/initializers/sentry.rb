Sentry.init do |config|
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters - %i[id])
  config.before_send = lambda do |event, _hint|
    # Only filter user-provided data, not system metadata
    if event.request
      event.request.data = filter.filter(event.request.data)
    end

    # Don't filter server_name and other metadata
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
  config.release = ENV.fetch("COMMIT_SHA", nil)
end
