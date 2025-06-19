require "rails_helper"

RSpec.describe "Jobseekers applications statuses" do
  let!(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [school], visa_sponsorship_available: true) }
  let(:school) { create(:school) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after { logout }

  context "when the jobseeker has a profile" do
    context "when the jobseeker has completed details in their profile" do
      let!(:jobseeker_profile) { create(:jobseeker_profile, :completed, jobseeker: jobseeker) }

      it "shows all sections with the status tag 'in progress'" do
        visit job_path(vacancy)
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

    context "when the jobseeker has not completed any details in their profile" do
      let!(:jobseeker_profile) { create(:jobseeker_profile, jobseeker: jobseeker, qualified_teacher_status: nil) }

      it "shows all sections with the status tag 'in progress'" do
        visit job_path(vacancy)
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
