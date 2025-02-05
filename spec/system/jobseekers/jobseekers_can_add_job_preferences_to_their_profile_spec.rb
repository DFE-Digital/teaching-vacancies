require "rails_helper"

RSpec.describe "Jobseekers can add job preferences to their profile" do
  let!(:jobseeker) { create(:jobseeker, :with_profile) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after { logout }

  describe "changing job preferences" do
    context "when adding job preferences" do
      before do
        visit jobseekers_profile_path
        create(:job_preferences, completed_steps: [], builder_completed: false, jobseeker_profile: jobseeker.jobseeker_profile)
      end

      it "allows jobseekers to add job preferences" do
        click_on "Add job preferences"

        check "Headteacher"
        click_on "Save and continue"

        check "Through school"
        click_on "Save and continue"

        check "I'm not looking for a teaching job"
        click_on "Save and continue"

        check "Part time"
        fill_in "job-preferences-working-pattern-details-field", with: "I am only available before 1pm."
        click_on "Save and continue"

        fill_in "Location", with: "London"
        choose "1 mile"
        click_on "Save and continue"

        choose "No"
        click_on "Save and continue"

        expect_page_to_have_values(role: "Headteacher", phase: "Through school", key_stage: "I'm not looking for a teaching job", working_patterns: "Part time", working_pattern_details: "I am only available before 1pm.", location: "London", location_radius: "1 mile")

        click_on "Return to profile"

        expect(page).to have_current_path(jobseekers_profile_path)

        expect_page_to_have_values(role: "Headteacher", phase: "Through school", key_stage: "I'm not looking for a teaching job", working_patterns: "Part time", working_pattern_details: "I am only available before 1pm.", location: "London", location_radius: "1 mile")
      end
    end

    context "when editing job preferences" do
      before do
        create(:job_preferences, :with_locations, working_patterns: %w[part_time], working_pattern_details: "I cannot work on Mondays or Fridays", jobseeker_profile: jobseeker.jobseeker_profile)
        visit jobseekers_profile_path
      end

      it "allows jobseeker to edit job preferences" do
        expect(page).to have_css(".govuk-summary-list__key", text: "Working pattern details")
        expect(page).to have_css(".govuk-summary-list__value", text: "I cannot work on Mondays or Fridays")

        click_on("Change Working pattern details")
        fill_in "job-preferences-working-pattern-details-field", with: "On second thoughts, I can only work Wednesdays"
        click_on "Save and continue"

        expect(page).to have_css(".govuk-summary-list__key", text: "Working pattern details")
        expect(page).to have_css(".govuk-summary-list__value", text: "On second thoughts, I can only work Wednesdays")

        click_on "Return to profile"

        expect(page).to have_current_path(jobseekers_profile_path)

        expect(page).to have_css(".govuk-summary-list__key", text: "Working pattern details")
        expect(page).to have_css(".govuk-summary-list__value", text: "On second thoughts, I can only work Wednesdays")
      end
    end
  end

  def expect_page_to_have_values(role:, phase:, key_stage:, working_patterns:, location:, location_radius:, working_pattern_details: nil)
    expect(page).to have_css(".govuk-summary-list__key", text: "Role")
    expect(page).to have_css(".govuk-summary-list__value", text: role)

    expect(page).to have_css(".govuk-summary-list__key", text: "Education phase")
    expect(page).to have_css(".govuk-summary-list__value", text: phase)

    expect(page).to have_css(".govuk-summary-list__key", text: "Key stage")
    expect(page).to have_css(".govuk-summary-list__value", text: key_stage)

    expect(page).to have_css(".govuk-summary-list__key", text: "Working pattern")
    expect(page).to have_css(".govuk-summary-list__value", text: working_patterns)

    if working_pattern_details
      expect(page).to have_css(".govuk-summary-list__key", text: "Working pattern details")
      expect(page).to have_css(".govuk-summary-list__value", text: working_pattern_details)
    end

    expect(page).to have_css(".govuk-summary-list__key", text: "Location")
    expect(page).to have_css(".govuk-summary-list__value", text: "#{location} (#{location_radius})")
  end
end
