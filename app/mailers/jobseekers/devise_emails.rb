module Jobseekers::DeviseEmails
  def confirmation_instructions(record, token, _opts = {})
    to = subject = nil

    if !record.confirmed? && record.confirmation_sent_at < 12.hours.ago
      to = record.unconfirmed_email
      subject = t(".reminder.subject")
      @confirmation_type = ".reminder"
    elsif record.pending_reconfirmation?
      to = record.unconfirmed_email
      subject = t(".reconfirmation.subject")
      @confirmation_type = ".reconfirmation"
    end

    send_email(
      jobseeker: record,
      subject: subject,
      template: template,
      to: to,
      token: token,
    )
  end

  def email_changed(record, _opts = {})
    send_email(
      jobseeker: record,
      template: template,
    )
  end

  def reset_password_instructions(record, token, _opts = {})
    send_email(
      jobseeker: record,
      template: template,
      token: token,
    )
  end

  def unlock_instructions(record, token, _opts = {})
    send_email(
      jobseeker: record,
      template: template,
      token: token,
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
    @subject = (subject || t(".subject"))
    @template = template
    @to = (to || jobseeker.email)
    @token = token

    view_mail(
      template,
      to: @to,
      subject: @subject,
    )
  end

  def email_event_data
    case action_name
    when "confirmation_instructions"
      @jobseeker.pending_reconfirmation? ? { previous_email_identifier: StringAnonymiser.new(@jobseeker.email).to_s } : {}
    else
      {}
    end
  end

  def dfe_analytics_custom_data
    case action_name
    when "confirmation_instructions"
      @jobseeker.pending_reconfirmation? ? { previous_email_identifier: DfE::Analytics.anonymise(@jobseeker.email) } : {}
    else
      {}
    end
  end
end
