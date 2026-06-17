require "rails_helper"

RSpec.describe "Jobseekers can manage their saved jobs" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }

  let(:vacancy2) { create(:vacancy, enable_job_applications: true, organisations: [organisation]) }
  let(:expired_vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:expired_external_vacancy) { create(:vacancy, :external, :expired, organisations: [organisation]).tap(&:discard!) }

  context "when logged in" do
    before { login_as(jobseeker, scope: :jobseeker) }

    after { logout }

    context "when there are saved jobs" do
      before do
        jobseeker.saved_jobs.create(vacancy: vacancy2)
        jobseeker.saved_jobs.create(vacancy: expired_vacancy)
        jobseeker.saved_jobs.create(vacancy: expired_external_vacancy)

        visit jobseekers_saved_jobs_path
      end

      it "passes a11y", :a11y do
        expect(page).to be_axe_clean
      end

      scenario "when applying to a saved job redirects to the new job application page" do
        click_on I18n.t("jobseekers.saved_jobs.index.apply")
        expect(current_path).to eq(new_jobseekers_job_job_application_path(vacancy2.id))
      end

      scenario "deleting an expired saved job redirects to the dashboard" do
        click_on I18n.t("jobseekers.saved_jobs.index.delete"), match: :first
        expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
        expect(page).to have_content(I18n.t("jobseekers.saved_jobs.destroy.success"))
        expect(page).to have_css(".card-component", count: 2)
      end

      scenario "deleting an expired soft-deleted saved job redirects to the dashboard" do
        within ".card-component:nth-child(3)" do
          click_on I18n.t("jobseekers.saved_jobs.index.delete")
        end
        expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
        expect(page).to have_content(I18n.t("jobseekers.saved_jobs.destroy.success"))
        expect(page).to have_css(".card-component", count: 2)
      end
    end
  end

  context "when logged out" do
    before { visit jobseekers_saved_jobs_path }

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
