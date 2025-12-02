class Jobseekers::ProfilesMailer < Jobseekers::BaseMailer
  def disable_inactive_profile(profile)
    @profile = profile
    send_email(to: profile.email, subject: I18n.t("jobseekers.profiles_mailer.disable_inactive_profile.subject"))
  end

  def inactive_profile_warning(profile, expiry_date)
    @profile = profile
    @expiry_date = expiry_date
    send_email(to: profile.email, subject: I18n.t("jobseekers.profiles_mailer.inactive_profile_warning.subject"))
  end
end
