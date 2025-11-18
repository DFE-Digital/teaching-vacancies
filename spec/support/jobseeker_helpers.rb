module JobseekerHelpers
  def validates_step_complete(button: I18n.t("buttons.save_and_continue"))
    click_on button
    within ".govuk-error-summary" do
      expect(page).to have_content("There is a problem")
    end
  end

  def select_qualification_category(category)
    choose category
    click_on I18n.t("buttons.continue")
  end

  def fill_in_ask_for_support
    choose "Yes", name: "jobseekers_job_application_ask_for_support_form[is_support_needed]"
    fill_in "Tell us any information you think is relevant", with: "Some details about support"
    choose I18n.t("helpers.label.jobseekers_job_application_ask_for_support_form.ask_for_support_section_completed_options.true")
  end

  def fill_in_current_role(form:, start_month: "07", start_year: "2020")
    fill_in I18n.t("helpers.label.#{form}.organisation"), with: "Super School"
    fill_in I18n.t("helpers.label.#{form}.job_title"), with: "The Best Teacher"
    fill_in I18n.t("helpers.label.#{form}.main_duties"), with: "Goals and that"
    fill_in I18n.t("helpers.label.#{form}.reason_for_leaving"), with: "I hate it there"

    if I18n.exists?("helpers.label.#{form}.subjects_html")
      fill_in "Subjects and key stages taught (optional field)", with: "English KS1"
    end

    fill_in "#{form}[started_on(1i)]", with: start_year
    fill_in "#{form}[started_on(2i)]", with: start_month
    check "I currently work here"
  end

  def fill_in_declarations
    within ".close-relationships" do
      choose "Yes", name: "jobseekers_job_application_declarations_form[has_close_relationships]"
      fill_in "Please give details", with: "Some details of the relationship"
    end
    choose "Yes, I want to share something"
    fill_in "Give any relevant information", with: "Criminal record"
    choose I18n.t("helpers.label.jobseekers_job_application_declarations_form.declarations_section_completed_options.true")
    within ".life-abroad" do
      choose "Yes"
      fill_in "Please give details", with: "lived in patagonia"
    end
  end

  def fill_in_employment_history(job_title: "The Best Teacher", start_month: "09", start_year: "2019", end_month: "07", end_year: "2020")
    fill_in "School or other organisation", with: "The Best School"
    fill_in "Job title", with: job_title
    fill_in "Main duties", with: "Some details about what the main duties were"
    fill_in "Reason for leaving role", with: "Just couldn't take it any longer"
    fill_in "jobseekers_job_application_details_employment_form[started_on(1i)]", with: start_year
    fill_in "jobseekers_job_application_details_employment_form[started_on(2i)]", with: start_month
    fill_in "jobseekers_job_application_details_employment_form[ended_on(1i)]", with: end_year
    fill_in "jobseekers_job_application_details_employment_form[ended_on(2i)]", with: end_month
  end

  def fill_in_training_and_cpds(name: "Fire safety", provider: "TrainingProvider ltd", grade: "Pass", year_awarded: "2020", course_length: "1 year")
    fill_in "Name of course or training", with: name
    fill_in "Training provider", with: provider
    fill_in "Grade", with: grade
    fill_in "Date completed", with: year_awarded
    fill_in "Course length", with: course_length
  end

  def fill_in_break_in_employment(start_year: "2020", start_month: "08", end_year: "2020", end_month: "12")
    fill_in "Enter reasons for gap in work history", with: "Caring for a person"
    fill_in "jobseekers_break_form[started_on(1i)]", with: start_year
    fill_in "jobseekers_break_form[started_on(2i)]", with: start_month
    fill_in "jobseekers_break_form[ended_on(1i)]", with: end_year
    fill_in "jobseekers_break_form[ended_on(2i)]", with: end_month
  end

  def fill_in_equal_opportunities
    choose "Prefer not to say", name: "jobseekers_job_application_equal_opportunities_form[disability]"
    choose "Under 25", name: "jobseekers_job_application_equal_opportunities_form[age]"
    choose "Man", name: "jobseekers_job_application_equal_opportunities_form[gender]"
    choose "Bisexual", name: "jobseekers_job_application_equal_opportunities_form[orientation]"
    choose "Mixed", name: "jobseekers_job_application_equal_opportunities_form[ethnicity]"
    choose "Other", name: "jobseekers_job_application_equal_opportunities_form[religion]"
    fill_in strip_tags(I18n.t("helpers.label.jobseekers_job_application_equal_opportunities_form.religion_description_html")), with: "Jainism"

    choose I18n.t("helpers.label.jobseekers_job_application_equal_opportunities_form.equal_opportunities_section_completed_options.true")
  end

  def fill_in_personal_details
    fill_in "First name", with: Faker::Name.first_name
    fill_in "Last name", with: Faker::Name.last_name
    fill_in "Building and street", with: Faker::Address.street_address
    fill_in "Town or city", with: Faker::Address.city
    fill_in "Postcode", with: Faker::Address.postcode
    fill_in "Country", with: "United Kingdom"
    fill_in "Phone number", with: Faker::PhoneNumber.phone_number
    fill_in "Email address", with: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)
    check "Part time"
    fill_in "jobseekers_job_application_personal_details_form[working_pattern_details]", with: "I only work on days starting with T sorry."
    choose I18n.t("jobseekers.profiles.personal_details.work.options.true")
    choose I18n.t("helpers.label.jobseekers_job_application_personal_details_form.has_ni_number_options.yes")
    fill_in I18n.t("helpers.label.jobseekers_job_application_personal_details_form.national_insurance_number"), with: "AB 12 12 12 A"

    choose I18n.t("helpers.label.jobseekers_job_application_personal_details_form.personal_details_section_completed_options.true")
  end

  def fill_in_personal_statement
    fill_in "Your personal statement", with: "A brilliant, glowing statement about your person"
    choose I18n.t("helpers.label.jobseekers_job_application_personal_statement_form.personal_statement_section_completed_options.true")
  end

  def fill_in_professional_status
    choose "Yes", name: "jobseekers_job_application_professional_status_form[qualified_teacher_status]"
    fill_in "Year QTS was awarded", with: Time.current.year
    fill_in "What is your teacher reference number (TRN)?", with: "1234567"
    choose "Yes", name: "jobseekers_job_application_professional_status_form[is_statutory_induction_complete]"

    choose I18n.t("helpers.label.jobseekers_job_application_professional_status_form.professional_status_section_completed_options.true")
  end

  def fill_in_referee
    fill_in "Name", with: "Jim Referee"
    fill_in "Job title", with: "Important job"
    fill_in "Organisation", with: "Important organisation"
    fill_in "Relationship to applicant", with: "Colleague"
    fill_in "Email address", with: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN)
    fill_in "Phone number", with: "09999 123456"
    choose("Yes")
  end

  def fill_in_gcses
    fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][0][subject]", with: "Maths"
    fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][0][grade]", with: "110%"
    fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][0][awarding_body]", with: "Cambridge Board"
    find_by_id("add_subject").click
    fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][1][subject]", with: "PE"
    fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][1][grade]", with: "90%"
    fill_in "jobseekers_qualifications_secondary_common_form[institution]", with: "Churchill School for Gifted Macaques"
    fill_in "jobseekers_qualifications_secondary_common_form[year]", with: "2020"
  end

  def fill_in_undergraduate_degree
    fill_in "Subject", with: "Linguistics"
    fill_in "Awarding body", with: "University of Life"
    choose "Yes", name: "jobseekers_qualifications_degree_form[finished_studying]"
    fill_in "Grade", with: "2:1"
    fill_in "Year", with: "1960"
  end

  def fill_in_other_qualification
    fill_in "Qualification or course name", with: "Superteacher Certificate"
    fill_in "School, college, university or other organisation", with: "Teachers Academy"
    fill_in "Awarding body (optional)", with: "AXA"
    fill_in "Subject", with: "Superteaching"
    choose "No", name: "jobseekers_qualifications_other_form[finished_studying]"
    fill_in "Please give details", with: "I expect to finish next year"
  end

  def fill_in_professional_body_membership
    fill_in "Name of professional body", with: "Teachers Union"
    fill_in "Membership type or level (optional)", with: "Gold"
    fill_in "Membership or registration number (optional)", with: "42"
    fill_in "Date obtained (optional)", with: "2020"
    choose "Yes"
  end

  def expect_work_history_to_be_ordered_most_recent_first
    start_dates = all(".govuk-summary-list__row dt", text: "Start date").map { |dt| dt.find("+ dd").text }

    parsed_dates = start_dates.map { |date| Date.strptime(date, "%B %Y") }

    expect(parsed_dates).to eq parsed_dates.sort.reverse
  end
end
