require "rails_helper"

RSpec.describe "Jobseekers can manage their saved jobs" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
  end

  context "when logged in" do
    before do
      login_as(jobseeker, scope: :jobseeker)
    end

    context "when there are saved jobs" do
      let(:school) { create(:school) }
      let(:vacancy_1) { create(:vacancy) }
      let(:vacancy_2) { create(:vacancy) }
      let(:expired_vacancy) { create(:vacancy, :expired) }

      before do
        vacancy_1.organisation_vacancies.create(organisation: school)
        vacancy_2.organisation_vacancies.create(organisation: school)
        expired_vacancy.organisation_vacancies.create(organisation: school)

        jobseeker.saved_jobs.create(vacancy: vacancy_1)
        jobseeker.saved_jobs.create(vacancy: vacancy_2)
        jobseeker.saved_jobs.create(vacancy: expired_vacancy)

        visit jobseekers_saved_jobs_path
      end

      context "when the jobseeker views saved jobs" do
        it "shows saved jobs" do
          expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(page).to have_content(vacancy_1.job_title)
          expect(page).to have_content(vacancy_2.job_title)
          expect(page).to have_content(expired_vacancy.job_title)
        end

        it "renders deadline passed label for expired jobs" do
          within "tr[data-slug='#{vacancy_1.slug}']" do
            expect(page).not_to have_content(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          end

          within "tr[data-slug='#{vacancy_2.slug}']" do
            expect(page).not_to have_content(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          end

          within "tr[data-slug='#{expired_vacancy.slug}']" do
            expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          end
        end
      end

      context "when the jobseeker deletes a saved job" do
        before do
          within "tr[data-slug='#{vacancy_1.slug}']" do
            click_on "Delete"
          end
        end

        it "deletes the saved job and redirects to the dashboard" do
          expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(page).to have_content(I18n.t("jobseekers.saved_jobs.destroy.success"))
          expect(page).not_to have_content(vacancy_1.job_title)
          expect(page).to have_content(vacancy_2.job_title)
          expect(page).to have_content(expired_vacancy.job_title)
        end
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
