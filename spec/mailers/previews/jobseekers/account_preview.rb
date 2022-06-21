# Documentation: app/mailers/previewing_emails.md
class Jobseekers::AccountPreview < ActionMailer::Preview
  def account_closed
    Jobseekers::AccountMailer.account_closed(Jobseeker.first)
  end

  def confirmation_instructions
    Jobseekers::AccountMailer.confirmation_instructions(Jobseeker.first, "fake_token")
  end

  def confirmation_instructions_reminder
    jobseeker = FactoryBot.build(:jobseeker, confirmed_at: nil, confirmation_sent_at: 5.days.ago)
    Jobseekers::AccountMailer.confirmation_instructions(jobseeker, "fake_token")
  end

  def reconfirmation_instructions
    jobseeker = FactoryBot.build(:jobseeker, email: "oldemail@example.com", unconfirmed_email: "newemail@example.com")
    Jobseekers::AccountMailer.confirmation_instructions(jobseeker, "fake_token")
  end

  def email_changed
    Jobseekers::AccountMailer.email_changed(Jobseeker.first)
  end

  def inactive_account
    Jobseekers::AccountMailer.inactive_account(Jobseeker.first)
  end

  def reset_password_instructions
    Jobseekers::AccountMailer.reset_password_instructions(Jobseeker.first, "fake_token")
  end

  def unlock_instructions
    Jobseekers::AccountMailer.unlock_instructions(Jobseeker.first, "fake_token")
  end
end
