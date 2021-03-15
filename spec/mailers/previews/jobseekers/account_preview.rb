# Documentation: app/mailers/previewing_emails.md
class Jobseekers::AccountPreview < ActionMailer::Preview
  def confirmation_instructions
    Jobseekers::AccountMailer.confirmation_instructions(Jobseeker.first, "fake_token")
  end

  def email_changed
    Jobseekers::AccountMailer.email_changed(Jobseeker.first)
  end

  def reset_password_instructions
    Jobseekers::AccountMailer.reset_password_instructions(Jobseeker.first, "fake_token")
  end

  def unlock_instructions
    Jobseekers::AccountMailer.unlock_instructions(Jobseeker.first, "fake_token")
  end
end
