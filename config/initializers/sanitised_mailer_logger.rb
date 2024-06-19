require "json"

class SanitisedMailerLogger < Logger
  def initialize(*args)
    super
    @formatter = proc do |severity, timestamp, progname, msg|
      format_message(severity, timestamp, progname, msg)
    end
  end

  def format_message(severity, timestamp, progname, msg)
    msg = msg.to_json if msg.is_a?(Hash)

    sanitized_message = msg.gsub(/"to":\[\s*"[^\"]+"\s*\]/, '"to":["[FILTERED]"]')
    "#{timestamp} #{severity} #{progname}: #{sanitized_message}\n"
  end
end

ActionMailer::Base.logger = SanitisedMailerLogger.new($stdout)
