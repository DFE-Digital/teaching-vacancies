module JobseekerHelpers
  def resend_confirmation_email
    visit first_link_from_last_mail
    click_on I18n.t("buttons.resend_email")
  end

  def resend_unlock_instructions_email
    fill_in "Email address", with: jobseeker.email
    within(".new_jobseeker") do
      click_on I18n.t("jobseekers.unlocks.new.form_submit")
    end
  end

  def sign_up_jobseeker(email: jobseeker.email, password: jobseeker.password)
    fill_in "Email address", with: email
    fill_in "Password", with: password
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
