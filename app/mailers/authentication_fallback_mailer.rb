class AuthenticationFallbackMailer < ApplicationMailer
  # This is not a key, it is the uid of a template.
  NOTIFY_GENERIC_EMAIL_TEMPLATE = "2f37ec1d-58ef-4cd9-9d0a-4272723dda3d".freeze

  def sign_in_fallback(login_key:, publisher:)
    @template = NOTIFY_GENERIC_EMAIL_TEMPLATE
    @publisher = publisher
    @to = publisher.email

    @login_link = auth_email_choose_organisation_url(login_key: login_key.id)

    view_mail(@template, to: @to, subject: I18n.t("publishers.temp_login.email.subject"))
  end

  private

  def email_event
    @email_event ||= EmailEvent.new(@template, @to, publisher: @publisher)
  end

  def email_event_prefix
    "publisher"
  end
end
