class SanitizedMailerLogger < ActiveSupport::Logger
  def format_message(severity, timestamp, progname, msg)
    filtered_message = msg.gsub(/"to":\["[^"]+"\]/, '"to":["[FILTERED]"]')
    super(severity, timestamp, progname, filtered_message)
  end
end

ActionMailer::Base.logger = SanitizedMailerLogger.new($stdout)
