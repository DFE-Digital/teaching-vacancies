require "semantic_logger"
require "json"

class CustomLogFormatter < SemanticLogger::Formatters::Raw
  def call(log, logger)
    super

    if hash["payload"].is_a?(Hash) && hash["payload"]["to"]
      hash["payload"].delete("to")
    end

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
