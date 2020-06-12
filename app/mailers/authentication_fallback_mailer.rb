class AuthenticationFallbackMailer < ApplicationMailer
  # This is not a key, it is the uid of a template.
  NOTIFY_GENERIC_EMAIL_TEMPLATE = '2f37ec1d-58ef-4cd9-9d0a-4272723dda3d'.freeze
  
  def sign_in_fallback(login_key:, email:)
    @login_link = sign_in_by_email_url(login_key: login_key.id)
    view_mail(
      NOTIFY_GENERIC_EMAIL_TEMPLATE,
      to: email,
      subject: I18n.t('hiring_staff.identifications.temp_login.email.subject'),
    )
  end
end
