Sentry.init do |config|
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, _hint|
    filter.filter(event.to_hash)
  end

  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  config.environment = Rails.application.config.app_role
  config.release = ENV["COMMIT_SHA"]
end
