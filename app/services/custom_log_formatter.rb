require "semantic_logger"

class CustomLogFormatter < SemanticLogger::Formatters::Raw
  REDACTED = "[REDACTED]".freeze

  def call(log, logger)
    super

    return unless hash[:payload].present?

    hash[:payload][:subject] = REDACTED if hash.dig(:payload, :subject).present?
    hash[:payload][:to] = REDACTED if hash.dig(:payload, :to).present?

    hash.to_json
  end
end
