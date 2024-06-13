class SanitisedMailerLogger < Logger
  def initialize(*args)
    super
    @formatter = proc do |severity, timestamp, progname, msg|
      format_message(severity, timestamp, progname, msg)
    end
  end

  def format_message(severity, timestamp, progname, msg)
    sanitized_message = msg.gsub(/"to":\[\s*"[^\"]+"\s*\]/, '"to":["[FILTERED]"]')
    "#{timestamp} #{severity} #{progname}: #{sanitized_message}\n"
  end
end

ActionMailer::Base.logger = SanitisedMailerLogger.new($stdout)
