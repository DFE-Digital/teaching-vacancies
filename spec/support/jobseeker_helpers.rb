module JobseekerHelpers
  def confirm_email_address
    visit jobseeker_confirmation_path(confirmation_token: created_jobseeker.confirmation_token)
  end

  def resend_confirmation_email
    confirm_email_address
    click_on I18n.t("buttons.resend_email")
  end

  def sign_up_jobseeker
    fill_in "Email address", with: jobseeker.email
    fill_in "Password", with: jobseeker.password
    click_on I18n.t("buttons.continue")
  end

  def sign_in_jobseeker(email: jobseeker.email, password: jobseeker.password)
    fill_in "Email address", with: email
    fill_in "Password", with: password
    within(".new_jobseeker") do
      click_on I18n.t("buttons.sign_in")
    end
  end
end
