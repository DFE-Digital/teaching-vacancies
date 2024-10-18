module Jobseekers::DeviseEmails
  def email_changed(record, _opts = {})
    send_email(
      jobseeker: record,
      template: template,
    )
  end

  def password_change(...)
    raise "Unused"
  end

  private

  def send_email(template:, jobseeker:, token: nil, to: nil, subject: nil)
    raise ArgumentError, "This mailer should only be used for jobseekers" unless jobseeker.is_a?(Jobseeker)

    # Some of these are required for the event data
    @jobseeker = jobseeker
    @subject = subject || t(".subject")
    @template = template
    @to = to || jobseeker.email
    @token = token

    view_mail(
      template,
      to: @to,
      subject: @subject,
    )
  end

  def dfe_analytics_custom_data
    {}
  end
end
