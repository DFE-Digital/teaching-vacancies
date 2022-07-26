class Publishers::AuthenticationFallbackMailer < Publishers::BaseMailer
  def sign_in_fallback(login_key_id:, publisher:)
    @template = general_template
    @publisher = publisher
    @to = publisher.email

    @login_token = login_key_id

    view_mail(@template, to: @to, subject: I18n.t("publishers.temp_login.email.subject"))
  end
end
