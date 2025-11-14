class SupportUsers::AuthenticationFallbackMailer < SupportUsers::BaseMailer
  def sign_in_fallback(support_user:, signed_id:)
    @support_user = support_user
    @to = support_user.email

    @signed_id = signed_id

    send_email(to: @to, subject: I18n.t("support_users.authentication_fallback_mailer.sign_in_fallback.subject"))
  end
end
