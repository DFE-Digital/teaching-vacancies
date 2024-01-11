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

  scenario "support users can list and see the Jobseekers Profile information through the Supportal" do
    profile = create(:jobseeker_profile,
                     :completed,
                     about_you: "I am a jobseeker",
                     qualified_teacher_status: "yes",
                     qualified_teacher_status_year: "2010")

    click_on "View service data"
    expect(page).to have_css("h1", text: "Service data")

    click_link "Jobseeker profiles"
    expect(page).to have_css("h1", text: "Service Jobseeker Profiles")

    click_link profile.id
    expect(page).to have_css("h1", text: profile.id)

    within(".govuk-summary-list") do
      expect(page).to have_row("Id", profile.id)
      expect(page).to have_row("Active", "true")
      expect(page).to have_row("About you", "I am a jobseeker")
      expect(page).to have_row("Qualified teacher status", "yes")
      expect(page).to have_row("Qualified teacher status year", "2010")
    end
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
