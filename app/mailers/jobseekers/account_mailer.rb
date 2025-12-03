module Jobseekers
  class AccountMailer < BaseMailer
    def account_closed(jobseeker)
      template_mail("6a371919-fc19-4848-94ea-9534287c1cf8",
                    to: jobseeker.email,
                    personalisation: { mail_to: t("help.email") })
    end

    def inactive_account(jobseeker)
      template_mail("55f4b949-c8bd-4be3-a18e-8a61eb20eef3",
                    to: jobseeker.email,
                    personalisation: { date: 2.weeks.from_now.to_date.to_fs(:day_month),
                                       sign_in_link: new_jobseeker_session_url })
    end

    def request_account_transfer(jobseeker)
      template_mail("505d36ee-b7cc-4697-a7b0-003cdc40df3f",
                    to: jobseeker.email,
                    personalisation: { mail_to: t("help.email"), token: jobseeker.account_merge_confirmation_code })
    end
  end
end
