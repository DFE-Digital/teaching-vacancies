require "rails_helper"

RSpec.describe "Jobseekers can manage their saved jobs" do
  let(:jobseeker) { create(:jobseeker) }

  context "when logged in" do
    before do
      login_as(jobseeker, scope: :jobseeker)
    end

    context "when there are saved jobs" do
      let(:school) { create(:school) }
      let(:vacancy1) { create(:vacancy) }
      let(:vacancy2) { create(:vacancy) }
      let(:expired_vacancy) { create(:vacancy, :expired) }

      before do
        vacancy1.organisation_vacancies.create(organisation: school)
        vacancy2.organisation_vacancies.create(organisation: school)
        expired_vacancy.organisation_vacancies.create(organisation: school)

        jobseeker.saved_jobs.create(vacancy: vacancy1)
        jobseeker.saved_jobs.create(vacancy: vacancy2)
        jobseeker.saved_jobs.create(vacancy: expired_vacancy)

        visit jobseekers_saved_jobs_path
      end

      context "when the jobseeker views saved jobs" do
        it "shows saved jobs" do
          expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(page).to have_content(vacancy1.job_title)
          expect(page).to have_content(vacancy2.job_title)
          expect(page).to have_content(expired_vacancy.job_title)
        end

        it "renders deadline passed label for expired jobs" do
          within "div[data-slug='#{vacancy1.slug}']" do
            expect(page).not_to have_content(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          end

          within "div[data-slug='#{vacancy2.slug}']" do
            expect(page).not_to have_content(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          end

          within "div[data-slug='#{expired_vacancy.slug}']" do
            expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          end
        end
      end

      context "when the jobseeker deletes a saved job" do
        before do
          within "div[data-slug='#{vacancy1.slug}']" do
            click_on "Delete"
          end
        end

        it "deletes the saved job and redirects to the dashboard" do
          expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(page).to have_content(I18n.t("jobseekers.saved_jobs.destroy.success"))
          expect(page).not_to have_content(vacancy1.job_title)
          expect(page).to have_content(vacancy2.job_title)
          expect(page).to have_content(expired_vacancy.job_title)
        end
      end
    end

    context "when there are no saved jobs" do
      before do
        visit jobseekers_saved_jobs_path
      end

      it "shows zero saved jobs" do
        expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.zero_saved_jobs_title"))
      end
    end
  end

  context "when logged out" do
    before do
      visit jobseekers_saved_jobs_path
    end

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
