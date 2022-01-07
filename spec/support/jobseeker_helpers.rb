module JobseekerHelpers
  def resend_confirmation_email
    visit first_link_from_last_mail
    click_on I18n.t("buttons.resend_email")
  end

  def confirm_email_address
    visit first_link_from_last_mail
    click_on "Confirm"
  end

  def sign_up_jobseeker(email: jobseeker.email, password: jobseeker.password)
    within(".new_jobseeker") do
      fill_in "Email address", with: email
      fill_in "Password", with: password
      click_on I18n.t("buttons.create_account")
    end
  end

  def sign_in_jobseeker(email: jobseeker.email, password: jobseeker.password)
    within(".new_jobseeker") do
      fill_in "Email address", with: email
      fill_in "Password", with: password
      click_on I18n.t("buttons.sign_in")
    end
  end

  def validates_step_complete(button: I18n.t("buttons.save_and_continue"))
    click_on button
    expect(page).to have_content("There is a problem")
  end

  def select_qualification_category(category)
    choose category
    click_on I18n.t("buttons.continue")
  end

  def fill_in_ask_for_support
    choose "Yes", name: "jobseekers_job_application_ask_for_support_form[support_needed]"
    fill_in "Tell us any information you think is relevant", with: "Some details about support"
  end

  def fill_in_current_role
    fill_in "School or other organisation", with: "The Best School"
    fill_in "Job title", with: "The Best Teacher"
    fill_in "Main duties", with: "Some details about what the main duties were"
    fill_in "jobseekers_job_application_details_employment_form[started_on(1i)]", with: "2019"
    fill_in "jobseekers_job_application_details_employment_form[started_on(2i)]", with: "09"
    choose "Yes", name: "jobseekers_job_application_details_employment_form[current_role]"
  end

  def fill_in_declarations
    choose "Yes", name: "jobseekers_job_application_declarations_form[close_relationships]"
    fill_in "Please give details", with: "Some details of the relationship"
    choose "Yes", name: "jobseekers_job_application_declarations_form[right_to_work_in_uk]"
  end

  def fill_in_employment_history
    fill_in "School or other organisation", with: "The Best School"
    fill_in "Job title", with: "The Best Teacher"
    fill_in "Main duties", with: "Some details about what the main duties were"
    fill_in "jobseekers_job_application_details_employment_form[started_on(1i)]", with: "2019"
    fill_in "jobseekers_job_application_details_employment_form[started_on(2i)]", with: "09"
    choose "No", name: "jobseekers_job_application_details_employment_form[current_role]"
    fill_in "jobseekers_job_application_details_employment_form[ended_on(1i)]", with: "2020"
    fill_in "jobseekers_job_application_details_employment_form[ended_on(2i)]", with: "07"
  end

  def fill_in_break_in_employment
    fill_in "Enter reasons for break in work history", with: "Caring for a person"
    fill_in "jobseekers_job_application_details_break_form[started_on(1i)]", with: "2020"
    fill_in "jobseekers_job_application_details_break_form[started_on(2i)]", with: "08"
    fill_in "jobseekers_job_application_details_break_form[ended_on(1i)]", with: "2020"
    fill_in "jobseekers_job_application_details_break_form[ended_on(2i)]", with: "12"
  end

  def fill_in_equal_opportunities
    choose "Prefer not to say", name: "jobseekers_job_application_equal_opportunities_form[disability]"
    choose "Under 25", name: "jobseekers_job_application_equal_opportunities_form[age]"
    choose "Man", name: "jobseekers_job_application_equal_opportunities_form[gender]"
    choose "Bisexual", name: "jobseekers_job_application_equal_opportunities_form[orientation]"
    choose "Mixed", name: "jobseekers_job_application_equal_opportunities_form[ethnicity]"
    choose "Other", name: "jobseekers_job_application_equal_opportunities_form[religion]"
    fill_in strip_tags(I18n.t("helpers.label.jobseekers_job_application_equal_opportunities_form.religion_description_html")), with: "Jainism"
  end

  def fill_in_personal_details
    fill_in "First name", with: "John"
    fill_in "Last name", with: "Frusciante"
    fill_in "Building and street", with: "123 Fake Street"
    fill_in "Town or city", with: "Fakeopolis"
    fill_in "Postcode", with: "F1 4KE"
    fill_in "Country", with: "United Kingdom"
    fill_in "Phone number", with: "01234 123456"
    fill_in "Email address", with: "jobseeker@example.com"
    fill_in "Teacher reference number", with: "1234567"
    fill_in "National Insurance number", with: "AB 12 12 12 A"
  end

  def fill_in_personal_statement
    fill_in "Your personal statement", with: "A brilliant, glowing statement about your person"
  end

  def fill_in_professional_status
    choose "Yes", name: "jobseekers_job_application_professional_status_form[qualified_teacher_status]"
    fill_in "Year QTS was awarded", with: Time.current.year
    choose "Yes", name: "jobseekers_job_application_professional_status_form[statutory_induction_complete]"
  end

  def fill_in_reference
    fill_in "Name", with: "Jim Referee"
    fill_in "Job title", with: "Important job"
    fill_in "Organisation", with: "Important organisation"
    fill_in "Relationship to applicant", with: "Colleague"
    fill_in "Email address", with: "test@example.net"
    fill_in "Phone number", with: "09999 123456"
  end

  def fill_in_gcses
    fill_in "jobseekers_job_application_details_qualifications_secondary_common_form[qualification_results_attributes][0][subject]", with: "Maths"
    fill_in "jobseekers_job_application_details_qualifications_secondary_common_form[qualification_results_attributes][0][grade]", with: "110%"
    fill_in "jobseekers_job_application_details_qualifications_secondary_common_form[qualification_results_attributes][1][subject]", with: "PE"
    fill_in "jobseekers_job_application_details_qualifications_secondary_common_form[qualification_results_attributes][1][grade]", with: "90%"
    fill_in "School, college, or other organisation", with: "Churchill School for Gifted Macaques"
    fill_in "Year qualification(s) was/were awarded", with: "2020"
  end

  def fill_in_custom_secondary_qualifications
    fill_in "Qualification name", with: "Welsh Baccalaureate"
    fill_in "jobseekers_job_application_details_qualifications_secondary_other_form[qualification_results_attributes][0][subject]", with: "Science"
    fill_in "jobseekers_job_application_details_qualifications_secondary_other_form[qualification_results_attributes][0][grade]", with: "5"
    fill_in "jobseekers_job_application_details_qualifications_secondary_other_form[qualification_results_attributes][1][subject]", with: "German"
    fill_in "jobseekers_job_application_details_qualifications_secondary_other_form[qualification_results_attributes][1][grade]", with: "4"
    fill_in "School, college, or other organisation", with: "Happy Rainbows School for High Achievers"
    fill_in "Year qualification(s) was/were awarded", with: "2020"
  end

  def fill_in_undergraduate_degree
    fill_in "Subject", with: "Linguistics"
    fill_in "Awarding body", with: "University of Life"
    choose "Yes", name: "jobseekers_job_application_details_qualifications_degree_form[finished_studying]"
    fill_in "Grade", with: "2:1"
    fill_in "Year", with: "1960"
  end

  def fill_in_other_qualification
    fill_in "Qualification or course name", with: "Superteacher Certificate"
    fill_in "School, college, university or other organisation", with: "Teachers Academy"
    choose "No", name: "jobseekers_job_application_details_qualifications_other_form[finished_studying]"
    fill_in "Please give details", with: "I expect to finish next year"
  end
end
