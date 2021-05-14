require "rails_helper"

RSpec.describe "Jobseekers can manage their saved jobs" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }

  let(:vacancy1) { create(:vacancy, enable_job_applications: false, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:vacancy2) { create(:vacancy, enable_job_applications: true, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:expired_vacancy) { create(:vacancy, :expired, organisation_vacancies_attributes: [{ organisation: organisation }]) }

  let(:jobseeker_applications_enabled?) { false }

  before { allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(jobseeker_applications_enabled?) }

  context "when logged in" do
    before { login_as(jobseeker, scope: :jobseeker) }

    context "when there are saved jobs" do
      before do
        jobseeker.saved_jobs.create(vacancy: vacancy1)
        jobseeker.saved_jobs.create(vacancy: vacancy2)
        jobseeker.saved_jobs.create(vacancy: expired_vacancy)

        visit jobseekers_saved_jobs_path
      end

      context "when viewing saved jobs" do
        it "shows saved jobs" do
          expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(page).to have_css("h1.govuk-heading-l", text: I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(page).to have_css(".card-component", count: 3) do |cards|
            expect(cards[0]).to have_css(".card-component__header", text: expired_vacancy.job_title)
            expect(cards[1]).to have_css(".card-component__header", text: vacancy2.job_title)
            expect(cards[2]).to have_css(".card-component__header", text: vacancy1.job_title)
          end
        end

        it "shows deadline passed label for expired jobs" do
          expect(page).to have_css(".card-component", count: 3) do |cards|
            expect(cards[0]).to have_css(".card-component__body", text: I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
            expect(cards[1]).not_to have_css(".card-component__body", text: I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
            expect(cards[2]).not_to have_css(".card-component__body", text: I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          end
        end

        it "does not show apply for this job links" do
          expect(page).to have_css(".card-component", count: 3) do |cards|
            expect(cards[0]).to have_css(".card-component__actions") do |actions|
              expect(actions).not_to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
            end

            expect(cards[1]).to have_css(".card-component__actions") do |actions|
              expect(actions).not_to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
            end

            expect(cards[2]).to have_css(".card-component__actions") do |actions|
              expect(actions).not_to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
            end
          end
        end

        context "when JobseekerApplicationsFeature is enabled" do
          let(:jobseeker_applications_enabled?) { true }

          it "shows apply for this job link for live jobs that can be applied to" do
            expect(page).to have_css(".card-component", count: 3) do |cards|
              expect(cards[0]).to have_css(".card-component__actions") do |actions|
                expect(actions).not_to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
              end

              expect(cards[1]).to have_css(".card-component__actions") do |actions|
                expect(actions).to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
              end

              expect(cards[2]).to have_css(".card-component__actions") do |actions|
                expect(actions).not_to have_link(I18n.t("jobseekers.saved_jobs.index.apply"))
              end
            end
          end

          context "when applying to a saved job" do
            before { click_on I18n.t("jobseekers.saved_jobs.index.apply") }

            it "redirects to the new job application page" do
              expect(current_path).to eq(new_jobseekers_job_job_application_path(vacancy2.id))
            end
          end
        end
      end

      context "when deleting a saved job" do
        before { click_on I18n.t("jobseekers.saved_jobs.index.delete"), match: :first }

        it "deletes the saved job and redirects to the dashboard" do
          expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(page).to have_content(I18n.t("jobseekers.saved_jobs.destroy.success"))
          expect(page).to have_css(".card-component", count: 2)
        end
      end
    end

    context "when there are no saved jobs" do
      before { visit jobseekers_saved_jobs_path }

      it "shows zero saved jobs" do
        expect(page).to have_content(I18n.t("jobseekers.saved_jobs.index.zero_saved_jobs_title"))
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
