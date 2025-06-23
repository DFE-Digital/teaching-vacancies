class Jobseekers::ProfilesMailer < Jobseekers::BaseMailer
  def disable_inactive_profile(profile)
    @profile = profile
    send_email(to: profile.email, subject: I18n.t("jobseekers.profiles_mailer.disable_inactive_profile.subject"))
  end

  def inactive_profile_warning(profile)
    @profile = profile
    send_email(to: profile.email, subject: I18n.t("jobseekers.profiles_mailer.inactive_profile_warning.subject"))
  end

  def disable_profile_due_to_new_fields(profile)
    @profile = profile
    send_email(to: profile.email, subject: I18n.t("jobseekers.profiles_mailer.disable_profile_due_to_new_fields.subject"))
  end
end

# One off email to let users know their profile has been deactivated due to missing mandatory information
#
# Subject line: Your Teaching Vacancies profile has been deactivated due to missing information
#
# Dear [first name],
#
#      We have deactivated your profile on Teaching Vacancies due to missing information. When your profile is active, school and trust hiring staff can view your details and contact you about jobs by email.
#
#   To reactivate your profile, [sign in to your Teaching Vacancies account](https://teaching-vacancies.service.gov.uk/jobseekers/sign-in), go to ‘Your profile’, complete the information required and select ‘Turn on profile’.
#
#   If you have followed the above advice and cannot reactivate your profile, contact [teaching.vacancies@education.gov.uk](mailto:teachingvacancies@education.gov.uk) for assistance.
#
#   Kind regards,
#
#        Teaching Vacancies team
#
