class JobseekerMailer < Devise::Mailer
  helper NotifyViewHelper
  include Devise::Controllers::UrlHelpers
  default template_path: "jobseeker_mailer"

  def confirmation_instructions(record, token, _opts = {})
    @jobseeker = record
    @token = token

    view_mail(
      NOTIFY_JOBSEEKER_CONFIRMATION_TEMPLATE,
      to: @jobseeker.pending_reconfirmation? ? @jobseeker.unconfirmed_email : @jobseeker.email,
      subject: I18n.t("jobseeker_mailer.confirmation_instructions.subject"),
    )
  end

  def email_changed(record, _opts = {})
    @jobseeker = record

    view_mail(
      NOTIFY_JOBSEEKER_EMAIL_CHANGED_TEMPLATE,
      to: @jobseeker.email,
      subject: I18n.t("jobseeker_mailer.email_changed.subject"),
    )
  end

  def reset_password_instructions(record, token, _opts = {})
    @jobseeker = record
    @token = token

    view_mail(
      NOTIFY_JOBSEEKER_RESET_PASSWORD_TEMPLATE,
      to: @jobseeker.email,
      subject: I18n.t("jobseeker_mailer.reset_password_instructions.subject"),
    )
  end

  def unlock_instructions(record, token, _opts = {})
    @jobseeker = record
    @token = token

    view_mail(NOTIFY_JOBSEEKER_LOCKED_ACCOUNT_TEMPLATE, to: @jobseeker.email, subject: t(".subject"))
  end
end
