class Jobseekers::AuthenticationFallbackMailer < Publishers::BaseMailer
  def sign_in_fallback(login_key_id:, jobseeker:)
    @template = template
    @jobseeker = jobseeker
    @to = jobseeker.email

    @login_token = login_key_id

    view_mail(@template, to: @to, subject: I18n.t("jobseekers.temp_login.email.subject"))
  end
end
