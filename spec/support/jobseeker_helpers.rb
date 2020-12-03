module JobseekerHelpers
  def confirm_email_address
    visit jobseeker_confirmation_path(confirmation_token: created_jobseeker.confirmation_token)
  end

  def resend_confirmation_email
    confirm_email_address
    click_on I18n.t("buttons.resend_email")
  end

  def sign_up_jobseeker
    fill_in "Email", with: jobseeker.email
    fill_in "Password", with: jobseeker.password
    click_on I18n.t("buttons.continue")
  end

  def sign_in_jobseeker
    fill_in "Email", with: jobseeker.email
    fill_in "Password", with: jobseeker.password
    click_on "Log in"
  end
end
