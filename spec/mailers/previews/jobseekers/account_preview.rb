# Documentation: app/mailers/previewing_emails.md
class Jobseekers::AccountPreview < ActionMailer::Preview
  def account_closed
    Jobseekers::AccountMailer.account_closed(Jobseeker.first)
  end

  def inactive_account
    Jobseekers::AccountMailer.inactive_account(Jobseeker.first)
  end
end
