class SanitisedMailerMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    original_logger = ActionMailer::Base.logger

    ActionMailer::Base.logger = SemanticLogger["SanitizedMailerLogger"]

    result = @app.call(env)

    ActionMailer::Base.logger = original_logger

    result
  end

  def self.sanitize(log)
    if log.is_a?(Hash)
      log = log.to_json
    end

    log.gsub(/"to":\[\s*"[^"]+"\s*\]/, '"to":["[FILTERED]"]')
  end
end
