class JobseekerMailer < Devise::Mailer
  helper NotifyViewHelper
  include Devise::Controllers::UrlHelpers
  default template_path: "jobseeker_mailer"

  def confirmation_instructions(record, token, _opts = {})
    @jobseeker = record
    @token = token

    view_mail(
      NOTIFY_JOBSEEKER_CONFIRMATION_TEMPLATE,
      to: @jobseeker.email,
      subject: I18n.t("jobseeker_mailer.confirmation_instructions.subject"),
    )
  end
end
