require "rails_helper"

RSpec.describe "Service Data supportal section" do
  before do
    OmniAuth.config.test_mode = true

    stub_support_user_authentication_step
    stub_support_user_authorisation_step

    sign_in_support_user(navigate: true)
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  it "support users can list and see the Jobseekers Profile information through the Supportal" do
    profile = create(:jobseeker_profile,
                     :completed,
                     about_you: "I am a jobseeker",
                     qualified_teacher_status: "yes",
                     qualified_teacher_status_year: "2010")
    jobseeker = profile.jobseeker
    personal_details = profile.personal_details
    jobseeker_name = "#{personal_details.first_name} #{personal_details.last_name}"

    click_on "View service data"
    expect(page).to have_css("h1", text: "Service data")

    click_link "Jobseeker profiles"
    expect(page).to have_css("h1", text: "Service Jobseeker Profiles")

    click_link jobseeker_name
    expect(page).to have_css("h1", text: jobseeker_name)

    within(summary_card("Jobseeker")) do
      expect(page).to have_row("Id", jobseeker.id)
      expect(page).to have_row("Email", jobseeker.email)
      expect(page).to have_row("Sign in count", "0")
      expect(page).to have_row("Failed attempts", "0")
      expect(page).to have_row("Confirmed at", jobseeker.confirmed_at)
    end

    within(summary_card("Personal Details")) do
      expect(page).to have_row("Id", personal_details.id)
      expect(page).to have_row("Phone number provided", "true")
      expect(page).to have_row("First name", personal_details.first_name)
      expect(page).to have_row("Last name", personal_details.last_name)
      expect(page).to have_row("Phone number", personal_details.phone_number)
      expect(page).to have_row("Right to work in uk", "true")
    end

    within(summary_card("Jobseeker Profile")) do
      expect(page).to have_row("Jobseeker", jobseeker.id)
      expect(page).to have_row("Active", "true")
      expect(page).to have_row("About you", "I am a jobseeker")
      expect(page).to have_row("Qualified teacher status", "yes")
      expect(page).to have_row("Qualified teacher status year", "2010")
    end

    preferences = profile.job_preferences
    within(summary_card("Job Preferences")) do
      expect(page).to have_row("Id", preferences.id)
      expect(page).to have_row("Roles", preferences.roles)
      expect(page).to have_row("Phases", preferences.phases)
      expect(page).to have_row("Key stages", preferences.key_stages)
      expect(page).to have_row("Subjects", preferences.subjects)
      expect(page).to have_row("Working patterns", preferences.working_patterns)
      expect(page).to have_row("Completed steps", preferences.completed_steps)
      expect(page).to have_row("Builder completed", preferences.builder_completed)
    end

    qualification = profile.qualifications.first
    within(summary_card(qualification.name)) do
      expect(page).to have_row("Id", qualification.id)
      expect(page).to have_row("Category", qualification.category)
      expect(page).to have_row("Finished studying", qualification.finished_studying)
      expect(page).to have_row("Finished studying details", qualification.finished_studying_details)
      expect(page).to have_row("Grade", qualification.grade)
      expect(page).to have_row("Institution", qualification.institution)
      expect(page).to have_row("Name", qualification.name)
      expect(page).to have_row("Subject", qualification.subject)
      expect(page).to have_row("Year", qualification.year)
    end

    employment = profile.employments.first
    within(summary_card(employment.job_title)) do
      expect(page).to have_row("Id", employment.id)
      expect(page).to have_row("Salary", employment.salary)
      expect(page).to have_row("Current role", employment.current_role)
      expect(page).to have_row("Started on", employment.started_on)
      expect(page).to have_row("Ended on", employment.ended_on)
      expect(page).to have_row("Employment type", employment.employment_type)
      expect(page).to have_row("Organisation", employment.organisation)
      expect(page).to have_row("Job title", employment.job_title)
      expect(page).to have_row("Main duties", employment.main_duties)
      expect(page).to have_row("Reason for leaving", employment.reason_for_leaving)
    end
  end

  def summary_card(title)
    find(".govuk-summary-card h3", text: title, exact_text: true).ancestor(".govuk-summary-card")
  end

  matcher :have_row do |key, value|
    match_unless_raises do |page|
      expect(page.find("dt.govuk-summary-list__key", text: key, exact_text: true))
        .to have_sibling("dd.govuk-summary-list__value", text: value, exact_text: true)
    end

    failure_message do |page|
      if page.has_css?("dt.govuk-summary-list__key", text: key, exact_text: true, wait: 0)
        value_content = page.first(:css, "dt.govuk-summary-list__key", text: key, exact_text: true)
                            .sibling("dd.govuk-summary-list__value").text
        "Expected page to have a row for '#{key}' with value '#{value}', but contained '#{value_content}'"
      else
        "Expected page to have a row for '#{key}' with value '#{value}', but there is no row for '#{key}'"
      end
    end
  end
end
