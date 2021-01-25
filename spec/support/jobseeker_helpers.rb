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

  def fill_in_ask_for_support
    choose "Yes", name: "jobseekers_job_application_ask_for_support_form[support_needed]"
    fill_in "Tell us any information you think is relevant", with: "Some details about support"
  end

  def fill_in_declarations
    choose "Yes", name: "jobseekers_job_application_declarations_form[banned_or_disqualified]"
    choose "Yes", name: "jobseekers_job_application_declarations_form[close_relationships]"
    fill_in "Please give details", with: "Some details of the relationship"
    choose "Yes", name: "jobseekers_job_application_declarations_form[right_to_work_in_uk]"
  end

  def fill_in_personal_details
    fill_in "First name", with: "John"
  end

  def fill_in_personal_statement
    fill_in "Your personal statement", with: "A brilliant, glowing statement about your person"
  end

  def fill_in_professional_status
    choose "Yes", name: "jobseekers_job_application_professional_status_form[qualified_teacher_status]"
    fill_in "Year QTS was awarded", with: Time.current.year
    choose "Yes", name: "jobseekers_job_application_professional_status_form[statutory_induction_complete]"
  end
end
