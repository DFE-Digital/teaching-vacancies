class Jobseekers::AuthenticationFallbackMailer < Publishers::BaseMailer
  def sign_in_fallback(login_key_id:, jobseeker:)
    @jobseeker = jobseeker

    @login_token = login_key_id

    send_email(to: jobseeker.email, subject: I18n.t("jobseekers.temp_login.email.subject"))
  end
end
