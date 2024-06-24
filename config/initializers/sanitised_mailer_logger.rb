require "semantic_logger"

class SanitisedMailerLogger < SemanticLogger::Appender::Wrapper
  def log(log)
    msg = log.message.is_a?(Hash) ? log.message.to_json : log.message

    sanitized_message = msg.gsub(/"to":\[\s*"[^"]+"\s*\]/, '"to":["[FILTERED]"]')

    log.message = sanitized_message

    super
  end
end

sanitised_logger = SanitisedMailerLogger.new(logger: SemanticLogger["SanitisedMailerLogger"])
ActionMailer::Base.logger = sanitised_logger
SemanticLogger.add_appender(io: $stdout, formatter: :json, appender: sanitised_logger)
