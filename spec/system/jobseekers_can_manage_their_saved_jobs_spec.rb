require "rails_helper"

RSpec.describe "Jobseekers can manage their saved jobs" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }

  let(:vacancy1) { create(:vacancy, apply_through_teaching_vacancies: "no", organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:vacancy2) { create(:vacancy, apply_through_teaching_vacancies: "yes", organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:expired_vacancy) { create(:vacancy, :expired, organisation_vacancies_attributes: [{ organisation: organisation }]) }

  let(:saved_jobs_page) { PageObjects::Jobseekers::SavedJobs::Index.new }
  let(:jobseeker_applications_enabled?) { false }

  before { allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(jobseeker_applications_enabled?) }

  context "when logged in" do
    before { login_as(jobseeker, scope: :jobseeker) }

    context "when there are saved jobs" do
      before do
        jobseeker.saved_jobs.create(vacancy: vacancy1)
        jobseeker.saved_jobs.create(vacancy: vacancy2)
        jobseeker.saved_jobs.create(vacancy: expired_vacancy)

        saved_jobs_page.load
      end

      context "when viewing saved jobs" do
        it "shows saved jobs" do
          expect(saved_jobs_page.heading).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(saved_jobs_page).to have_cards(count: 3)
          expect(saved_jobs_page.cards[0].header).to have_content(expired_vacancy.job_title)
          expect(saved_jobs_page.cards[1].header).to have_content(vacancy2.job_title)
          expect(saved_jobs_page.cards[2].header).to have_content(vacancy1.job_title)
        end

        it "shows deadline passed label for expired jobs" do
          expect(saved_jobs_page.cards[0].body).to have_content(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          expect(saved_jobs_page.cards[1].body).not_to have_content(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
          expect(saved_jobs_page.cards[2].body).not_to have_content(I18n.t("jobseekers.saved_jobs.index.deadline_passed"))
        end

        it "does not show apply for this job links" do
          expect(saved_jobs_page.cards[0].actions.links(text: I18n.t("jobseekers.saved_jobs.index.apply"))).to be_blank
          expect(saved_jobs_page.cards[1].actions.links(text: I18n.t("jobseekers.saved_jobs.index.apply"))).to be_blank
          expect(saved_jobs_page.cards[2].actions.links(text: I18n.t("jobseekers.saved_jobs.index.apply"))).to be_blank
        end

        context "when JobseekerApplicationsFeature is enabled" do
          let(:jobseeker_applications_enabled?) { true }

          it "shows apply for this job link for live jobs that can be applied to" do
            expect(saved_jobs_page.cards[0].actions.links(text: I18n.t("jobseekers.saved_jobs.index.apply"))).to be_blank
            expect(saved_jobs_page.cards[1].actions.links(text: I18n.t("jobseekers.saved_jobs.index.apply"))).not_to be_blank
            expect(saved_jobs_page.cards[2].actions.links(text: I18n.t("jobseekers.saved_jobs.index.apply"))).to be_blank
          end

          context "when applying to a saved job" do
            before { saved_jobs_page.cards[1].actions.links(text: I18n.t("jobseekers.saved_jobs.index.apply")).first.click }

            it "redirects to the new job application page" do
              expect(current_path).to eq(new_jobseekers_job_job_application_path(vacancy2.id))
            end
          end
        end
      end

      context "when deleting a saved job" do
        before { saved_jobs_page.cards[0].actions.inputs(class: "govuk-delete-link").first.click }

        it "deletes the saved job and redirects to the dashboard" do
          expect(saved_jobs_page.heading).to have_content(I18n.t("jobseekers.saved_jobs.index.page_title"))
          expect(saved_jobs_page).to have_content(I18n.t("jobseekers.saved_jobs.destroy.success"))
          expect(saved_jobs_page).to have_cards(count: 2)
        end
      end
    end

    context "when there are no saved jobs" do
      before { saved_jobs_page.load }

      it "shows zero saved jobs" do
        expect(saved_jobs_page).to have_content(I18n.t("jobseekers.saved_jobs.index.zero_saved_jobs_title"))
      end
    end
  end

  context "when logged out" do
    before { saved_jobs_page.load }

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
