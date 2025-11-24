module Jobseekers
  class ProfilesMailer < BaseMailer
    def disable_inactive_profile(profile)
      template_mail("8988abf4-e530-4ff0-ac2b-b692929fe4c6",
                    to: profile.email,
                    personalisation: {
                      first_name: first_name(profile),
                      sign_in_link: new_jobseeker_session_url,
                      link: t("help.email"),
                    })
    end

    def inactive_profile_warning(profile, expiry_date)
      template_mail("dcea907b-8a69-482a-98fb-9ada310c96d7",
                    to: profile.email,
                    personalisation: {
                      first_name: first_name(profile),
                      expiry_date: expiry_date.to_fs,
                      sign_in_link: new_jobseeker_session_url,
                    })
    end

    private

    def first_name(profile)
      profile.personal_details&.first_name || "Jobseeker"
    end
  end
end
