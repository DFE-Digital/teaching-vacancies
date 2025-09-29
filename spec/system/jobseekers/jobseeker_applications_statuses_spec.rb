require "rails_helper"

RSpec.describe "Jobseekers applications statuses" do
  let!(:jobseeker) { create(:jobseeker, jobseeker_profile: jobseeker_profile) }
  let(:vacancy) { create(:vacancy, organisations: [school], visa_sponsorship_available: true) }
  let(:school) { create(:school) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after { logout }

  context "when the jobseeker has a profile" do
    before do
      visit job_path(vacancy)
    end

    context "when the jobseeker has completed details in their profile", :a11y do
      let(:jobseeker_profile) { build(:jobseeker_profile, :completed) }

      it "passes accessibility checks" do
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"
      end

      it "shows all sections with the status tag 'incomplete'" do
        within ".banner-buttons" do
          click_on I18n.t("jobseekers.job_applications.banner_links.apply")
        end

        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"

        click_button "Start application"
        # wait for page load
        find(".govuk-notification-banner")

        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"

        expect(page).to have_css("#personal_details", text: I18n.t("shared.status_tags.incomplete"))
        expect(page).to have_css("#professional_status", text: I18n.t("shared.status_tags.incomplete"))
        expect(page).to have_css("#qualifications", text: I18n.t("shared.status_tags.incomplete"))
        expect(page).to have_css("#training_and_cpds", text: I18n.t("shared.status_tags.incomplete"))
        expect(page).to have_css("#employment_history", text: I18n.t("shared.status_tags.incomplete"))
      end
    end

    context "when the jobseeker has not completed any details in their profile" do
      let(:jobseeker_profile) { build(:jobseeker_profile, qualified_teacher_status: nil) }

      it "shows all sections with the status tag 'incomplete'" do
        within ".banner-buttons" do
          click_on I18n.t("jobseekers.job_applications.banner_links.apply")
        end

        click_button "Start application"

        expect(page).to have_css("#personal_details", text: I18n.t("shared.status_tags.incomplete"))
        expect(page).to have_css("#professional_status", text: I18n.t("shared.status_tags.incomplete"))
        expect(page).to have_css("#qualifications", text: I18n.t("shared.status_tags.incomplete"))
        expect(page).to have_css("#training_and_cpds", text: I18n.t("shared.status_tags.incomplete"))
        expect(page).to have_css("#employment_history", text: I18n.t("shared.status_tags.incomplete"))
      end
    end
  end
end
