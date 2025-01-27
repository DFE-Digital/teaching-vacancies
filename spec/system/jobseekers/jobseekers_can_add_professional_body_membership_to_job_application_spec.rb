require "rails_helper"

RSpec.describe "Jobseekers can add professional body memberships to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  after { logout }

  context "when adding a professional body membership" do
    before do
      visit jobseekers_job_application_build_path(job_application, :professional_body_memberships)
      click_on I18n.t("buttons.add_professional_body_membership")
    end

    it "allows jobseekers to add a professional body membership" do
      validates_step_complete(button: I18n.t("buttons.save_and_continue"))
      fill_in_professional_body_membership
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :professional_body_memberships), ignore_query: true)
      expect(page).to have_content(I18n.t("buttons.add_another_professional_body_membership"))
      expect(page).to have_css("h3", text: "Teachers Union")

      within(".govuk-summary-list") do
        rows = [
          { key: "Name of professional body", value: "Teachers Union" },
          { key: "Membership type or level (optional)", value: "Gold" },
          { key: "Membership or registration number (optional)", value: "42" },
          { key: "Date obtained (optional)", value: "2020" },
          { key: "Did you take an exam for this membership?", value: "Yes" },
        ]

        rows.each do |row|
          expect(page).to have_css(".govuk-summary-list__key", text: row[:key])
          expect(page).to have_css(".govuk-summary-list__value", text: row[:value])
        end
      end
    end
  end

  context "when jobseeker has existing professional body membership" do
    before do
      create(:professional_body_membership, job_application: job_application)
      visit jobseekers_job_application_build_path(job_application, :professional_body_memberships)
    end

    it "allows jobseekers to edit the professional body membership" do
      click_on I18n.t("buttons.change")
      expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :professional_body_memberships))
      fill_in "Name of professional body", with: "Teaching staff union"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_no_content("Teachers Union")
      expect(page).to have_content("Teaching staff union")
    end

    it "allows jobseekers to delete the professional body membership" do
      click_on I18n.t("buttons.delete")
      expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :professional_body_memberships))
      fill_in "Name of professional body", with: "Teaching staff union"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_no_content("Teachers Union")
      expect(page).to have_content("COnfirmation message")
    end
  end

  # name { "Teachers Union" }
  # membership_type { "Platinum" }
  # membership_number { "100" }
  # year_membership_obtained { "2020" }
  # exam_taken { true }
end
