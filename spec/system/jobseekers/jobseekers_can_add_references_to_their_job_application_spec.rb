require "rails_helper"

RSpec.describe "Jobseekers can add references to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy, referees: referees) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_build_path(job_application, :referees)
  end

  after { logout }

  context "without referees" do
    let(:referees) { [] }

    it "passes a11y", :a11y do
      #  https://github.com/alphagov/govuk-frontend/issues/979
      expect(page).to be_axe_clean.skipping "aria-allowed-attr"
    end

    it "shows no referees" do
      expect(page).to have_content("No referees specified")
    end

    context "when adding a referee" do
      before do
        click_on I18n.t("buttons.add_referee")
      end

      it "passes a11y", :a11y do
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
      end

      it "allows jobseekers to add references" do
        expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :referees))
        validates_step_complete(button: I18n.t("buttons.save_reference"))

        fill_in_referee

        click_on I18n.t("buttons.save_reference")

        expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :referees), ignore_query: true)
        expect(page).to have_content("Jim Referee")
      end
    end
  end

  context "when there is at least one reference" do
    let(:referees) { build_list(:referee, 1, name: "John") }

    it "allows jobseekers to delete references" do
      click_on I18n.t("buttons.delete")

      expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :referees), ignore_query: true)
      expect(page).to have_content(I18n.t("jobseekers.job_applications.referees.destroy.success"))
      expect(page).not_to have_content("John")
    end

    it "allows jobseekers to edit references" do
      click_on I18n.t("buttons.change")

      fill_in "Name", with: ""
      choose("Yes")
      validates_step_complete(button: I18n.t("buttons.save_reference"))

      fill_in "Name", with: "Jason"
      choose("No")
      click_on I18n.t("buttons.save_reference")

      expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :referees), ignore_query: true)
      within ".govuk-summary-card" do
        expect(page).not_to have_content("John")
        expect(page).not_to have_content("Yes")
        expect(page).to have_content("Jason")
        expect(page).to have_content("No")
      end
    end
  end
end
