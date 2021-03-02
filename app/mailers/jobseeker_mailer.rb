class JobseekerMailer < ApplicationMailer
  include Devise::Controllers::UrlHelpers
  default template_path: "jobseeker_mailer"

  def application_submitted(job_application)
    @vacancy = job_application.vacancy
    @organisation_name = @vacancy.parent_organisation.name
    @contact_email = @vacancy.contact_email
    @jobseeker = job_application.jobseeker

    @template = NOTIFY_APPLICATION_SUBMITTED_CONFIRMATION_TEMPLATE
    @to = job_application.jobseeker.email

    view_mail(@template, to: @to, subject: I18n.t("jobseeker_mailer.application_submitted.subject"))
  end

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

  def email_event_data
    case action_name
    when "confirmation_instructions"
      @jobseeker.pending_reconfirmation? ? { previous_email_identifier: StringAnonymiser.new(@jobseeker.email) } : {}
    else
      {}
    end
  end

  def email_event_prefix
    "jobseeker"
  end
end
