require "semantic_logger"
require "json"

class CustomLogFormatter < SemanticLogger::Formatters::Raw
  def call(log, logger)
    super

    hash["message"].reject! { |key, _| key == "to" }

    hash.to_json
  end
end

unless Rails.env.local?
  Rails.application.configure do
    config.semantic_logger.application = "" # No need to send the application name as logstash reads it from Cloud Foundry log tags
    config.active_record.logger = nil # Don't log SQL in production
    config.semantic_logger.backtrace_level = :error
  end

  SemanticLogger.add_appender(io: $stdout, level: Rails.application.config.log_level, formatter: CustomLogFormatter.new)
  Rails.logger.info("Application logging to STDOUT")
end
