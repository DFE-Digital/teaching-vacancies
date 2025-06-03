require "rails_helper"

RSpec.describe "Jobseekers can manage their job applications" do
  let(:jobseeker) { create(:jobseeker) }
  let(:organisation) { create(:school) }

  let(:vacancy1) { create(:vacancy, job_title: "Team Leader of Maths", organisations: [organisation]) }
  let(:vacancy2) { create(:vacancy, :expired, job_title: "Teacher of History", organisations: [organisation]) }
  let(:vacancy3) { create(:vacancy, job_title: "Teacher of Design & Technology", organisations: [organisation]) }
  let(:vacancy4) { create(:vacancy, job_title: "Teacher of RE & PSHE", organisations: [organisation]) }

  context "when logged in" do
    before do
      travel_to Time.zone.local(2025, 3, 2, 12, 31, 23)
      login_as(jobseeker, scope: :jobseeker)
    end

    after { logout }

    context "when there are job applications" do
      let!(:draft_job_application) { create(:native_job_application, updated_at: 1.day.ago, jobseeker: jobseeker, vacancy: vacancy1) }
      let!(:deadline_passed_job_application) { create(:native_job_application, updated_at: 2.days.ago, jobseeker: jobseeker, vacancy: vacancy2) }
      let!(:submitted_job_application) { create(:native_job_application, :status_submitted, submitted_at: 1.day.ago, jobseeker: jobseeker, vacancy: vacancy3) }
      let!(:shortlisted_job_application) { create(:native_job_application, :status_shortlisted, submitted_at: 2.days.ago, jobseeker: jobseeker, vacancy: vacancy4) }

      before { visit jobseekers_job_applications_path }

      context "when the jobseeker views job applications" do
        it "shows job applications in draft/submitted/shortlisted/passed order" do
          expect(page).to have_css("h1.govuk-heading-l", text: I18n.t("jobseekers.job_applications.index.page_title"))

          within ".card-component:nth-child(1)" do
            expect(page).to have_css(".card-component__header", text: draft_job_application.vacancy.job_title)
            expect(page).to have_css(".card-component__actions", text: "draft")
          end

          within ".card-component:nth-child(2)" do
            expect(page).to have_css(".card-component__header", text: submitted_job_application.vacancy.job_title)
            within ".card-component__body" do
              dt = find("dt", text: "Submitted")
              expect(dt.sibling("dd").text).to eq("1 March 2025 at 12:31pm")
            end
            expect(page).to have_css(".card-component__actions", text: "submitted")
          end

          within ".card-component:nth-child(3)" do
            expect(page).to have_css(".card-component__header", text: shortlisted_job_application.vacancy.job_title)
            expect(page).to have_css(".card-component__actions", text: "shortlisted")
          end

          within ".card-component:nth-child(4)" do
            expect(page).to have_css(".card-component__header", text: deadline_passed_job_application.vacancy.job_title)
            expect(page).to have_css(".card-component__actions", text: "deadline passed")
          end
        end

        it "can continue a draft application" do
          within ".card-component", text: draft_job_application.vacancy.job_title do
            click_on draft_job_application.vacancy.job_title
          end

          expect(current_path).to eq(jobseekers_job_application_apply_path(draft_job_application))
        end

        it "can not continue a draft application that has passed the deadline" do
          expect(page).to have_css(".card-component", text: deadline_passed_job_application.vacancy.job_title) do |card|
            expect(card).to have_css(".card-component__actions") do |actions|
              expect(actions).not_to have_link(I18n.t("jobseekers.job_applications.index.continue_application"))
            end
          end
        end

        it "can view a submitted application" do
          within ".card-component", text: submitted_job_application.vacancy.job_title do
            click_on submitted_job_application.vacancy.job_title
          end

          expect(current_path).to eq(jobseekers_job_application_path(submitted_job_application))
        end

        it "can delete a draft application" do
          within ".card-component", text: draft_job_application.vacancy.job_title do
            click_on draft_job_application.vacancy.job_title
          end
          click_on I18n.t("buttons.delete_application")

          expect(current_path).to eq(jobseekers_job_application_confirm_destroy_path(draft_job_application))
        end

        it "can withdraw a submitted application" do
          within ".card-component", text: submitted_job_application.vacancy.job_title do
            click_on submitted_job_application.vacancy.job_title
          end
          click_on I18n.t("buttons.withdraw_application")

          expect(current_path).to eq(jobseekers_job_application_confirm_withdraw_path(submitted_job_application))
        end
      end
    end

    context "when there are no job applications" do
      before { visit jobseekers_job_applications_path }

      it "shows zero job applications" do
        expect(page).to have_content(I18n.t("jobseekers.job_applications.index.no_job_applications"))
      end
    end
  end

  context "when logged out" do
    before { visit jobseekers_job_applications_path }

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
