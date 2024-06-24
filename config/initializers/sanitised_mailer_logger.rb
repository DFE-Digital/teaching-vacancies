require "semantic_logger"

class SanitisedMailerLogger < SemanticLogger::Appender::IO
  def log(log)
    log.message = SanitisedMailerMiddleware.sanitize(log.message)
    super
  end
end

wrapped_logger = SanitisedMailerLogger.new(io: $stdout, formatter: :json)
ActionMailer::Base.logger = wrapped_logger
SemanticLogger.add_appender(appender: wrapped_logger)
