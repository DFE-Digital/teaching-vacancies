require "rails_helper"

RSpec.describe "Jobseekers can add professional body memberships to their profile" do
  let(:jobseeker) { create(:jobseeker, jobseeker_profile: build(:jobseeker_profile, professional_body_memberships: professional_body_memberships)) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after { logout }

  describe "changing professional body memberships details" do
    before { visit jobseekers_profile_path }

    context "when adding professional body memberships" do
      let(:professional_body_memberships) { [] }

      it "allows jobseekers to add professional body memberships" do
        click_on "Add membership"

        click_on "Save and continue"

        expect(page).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
        within(".govuk-error-summary__body") do
          expect(page).to have_link("Enter the name of the professional body.", href: "#jobseekers-professional-body-membership-form-name-field-error")
        end

        fill_in_and_submit_form

        expect_page_to_have_values("Teachers Union", "Platinum", "100", "2020", "Yes")

        click_on "Return to profile"

        expect(page).to have_current_path(jobseekers_profile_path)

        expect_page_to_have_values("Teachers Union", "Platinum", "100", "2020", "Yes")
      end
    end

    context "when editing professional body memberships" do
      let(:professional_body_memberships) { build_list(:professional_body_membership, 1) }

      it "allows jobseeker to edit professional body memberships" do
        expect_page_to_have_values("Teachers Union", "Platinum", "100", "2020", "Yes")

        within(".govuk-summary-card__title-wrapper", text: "Teachers Union") do
          click_on("Change")
        end

        fill_in_and_submit_form(name: "Head teachers club")

        expect(page).to have_css(".govuk-summary-list__key", text: "Name of professional body")
        expect(page).to have_css(".govuk-summary-list__value", text: "Head teachers club")

        click_on "Return to profile"

        expect(page).to have_current_path(jobseekers_profile_path)

        expect(page).to have_css(".govuk-summary-list__key", text: "Name of professional body")
        expect(page).to have_css(".govuk-summary-list__value", text: "Head teachers club")
      end
    end

    context "when deleting professional body memberships" do
      let(:professional_body_memberships) { build_list(:professional_body_membership, 1) }

      it "allows users to delete professional body memberships" do
        expect_page_to_have_values("Teachers Union", "Platinum", "100", "2020", "Yes")

        within(".govuk-summary-card__title-wrapper", text: "Teachers Union") do
          click_on("Delete")
        end

        expect(page).to have_content "Confirm that you want to delete this professional body membership"

        click_on "Delete professional body membership"

        expect(page).to have_current_path(review_jobseekers_profile_professional_body_memberships_path)

        expect(page).to have_css("h2.govuk-notification-banner__title", text: "Success")
        expect(page).to have_css(".govuk-notification-banner__content", text: "Professional body membership deleted")

        expect(page).to have_no_css(".govuk-summary-list__value", text: "Teachers Union")
      end
    end
  end

  def fill_in_and_submit_form(name: "Teachers Union", membership_level: "Platinum", membership_number: "100", year_membership_obtained: "2020", exam_taken: "Yes")
    fill_in "Name of professional body", with: name
    fill_in "Membership type or level (optional)", with: membership_level
    fill_in "Membership or registration number (optional)", with: membership_number
    fill_in "Date obtained (optional)", with: year_membership_obtained
    choose exam_taken
    click_on "Save and continue"
  end

  def expect_page_to_have_values(name, provider, grade, year, course_length)
    expect(page).to have_css(".govuk-summary-list__key", text: "Name of professional body")
    expect(page).to have_css(".govuk-summary-list__value", text: name)

    expect(page).to have_css(".govuk-summary-list__key", text: "Membership type or level")
    expect(page).to have_css(".govuk-summary-list__value", text: provider)

    expect(page).to have_css(".govuk-summary-list__key", text: "Membership or registration number")
    expect(page).to have_css(".govuk-summary-list__value", text: grade)

    expect(page).to have_css(".govuk-summary-list__key", text: "Date obtained")
    expect(page).to have_css(".govuk-summary-list__value", text: year)

    expect(page).to have_css(".govuk-summary-list__key", text: "Did you take an exam for this membership?")
    expect(page).to have_css(".govuk-summary-list__value", text: course_length)
  end
end
