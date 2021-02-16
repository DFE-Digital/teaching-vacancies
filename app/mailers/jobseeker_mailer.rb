class JobseekerMailer < Devise::Mailer
  helper NotifyViewHelper
  include Devise::Controllers::UrlHelpers
  default template_path: "jobseeker_mailer"

  after_action :trigger_email_event

  def confirmation_instructions(record, token, _opts = {})
    @template = NOTIFY_JOBSEEKER_CONFIRMATION_TEMPLATE
    @jobseeker = record
    @to = @jobseeker.pending_reconfirmation? ? @jobseeker.unconfirmed_email : @jobseeker.email

    @token = token
    @confirmation_type = @jobseeker.pending_reconfirmation? ? ".reconfirmation" : ""

    view_mail(@template, to: @to, subject: t("#{@confirmation_type}.subject"))
  end

  def email_changed(record, _opts = {})
    @template = NOTIFY_JOBSEEKER_EMAIL_CHANGED_TEMPLATE
    @jobseeker = record
    @to = @jobseeker.email

    view_mail(@template, to: @to, subject: t(".subject"))
  end

  def reset_password_instructions(record, token, _opts = {})
    @template = NOTIFY_JOBSEEKER_RESET_PASSWORD_TEMPLATE
    @jobseeker = record
    @to = @jobseeker.email

    @token = token

    view_mail(@template, to: @to, subject: t(".subject"))
  end

  def unlock_instructions(record, token, _opts = {})
    @template = NOTIFY_JOBSEEKER_LOCKED_ACCOUNT_TEMPLATE
    @jobseeker = record
    @to = @jobseeker.email

    @token = token

    view_mail(@template, to: @to, subject: t(".subject"))
  end

  private

  def email_event
    @email_event ||= EmailEvent.new(@template, @to, jobseeker: @jobseeker)
  end

  def trigger_email_event
    data = case action_name
           when "confirmation_instructions"
             { previous_email_identifier: StringAnonymiser.new(@jobseeker.email) }
           else
             {}
           end

    email_event.trigger("jobseeker_#{action_name}".to_sym, data)
  end
end
