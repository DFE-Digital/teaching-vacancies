module Jobseekers::DeviseEmails
  # :nocov:
  def email_changed(record, _opts = {})
    send_devise_email(
      jobseeker: record,
    )
  end
  # :nocov:

  def password_change(...)
    raise "Unused"
  end

  private

  def send_devise_email(jobseeker:, token: nil, to: nil, subject: nil)
    raise ArgumentError, "This mailer should only be used for jobseekers" unless jobseeker.is_a?(Jobseeker)

    # Some of these are required for the event data
    @jobseeker = jobseeker
    @subject = subject || t(".subject")
    @token = token

    send_email(
      to: to || jobseeker.email,
      subject: @subject,
    )
  end

  def dfe_analytics_custom_data
    {}
  end
end
