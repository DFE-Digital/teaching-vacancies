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
  SemanticLogger.add_appender(
    io: $stdout,
    level: Rails.application.config.log_level,
    formatter: CustomLogFormatter.new,
  )
  Rails.logger.info("Application logging to STDOUT")
end
