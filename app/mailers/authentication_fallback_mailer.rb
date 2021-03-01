class AuthenticationFallbackMailer < ApplicationMailer
  def sign_in_fallback(login_key:, publisher:)
    @template = NOTIFY_PUBLISHER_AUTHENTICATION_FALLBACK_TEMPLATE
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
