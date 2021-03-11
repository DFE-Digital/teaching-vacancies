class Publishers::AuthenticationFallbackMailer < Publishers::BaseMailer
  def sign_in_fallback(login_key_id:, publisher:)
    @template = NOTIFY_PUBLISHER_AUTHENTICATION_FALLBACK_TEMPLATE
    @publisher = publisher
    @to = publisher.email

    @login_link = auth_email_choose_organisation_url(login_key: login_key_id)

    view_mail(@template, to: @to, subject: I18n.t("publishers.temp_login.email.subject"))
  end
end
