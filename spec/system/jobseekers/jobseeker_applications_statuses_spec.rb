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

        expect(page).to have_css("#personal_details", text: "in progress")
        expect(page).to have_css("#professional_status", text: "in progress")
        expect(page).to have_css("#qualifications", text: "in progress")
        expect(page).to have_css("#training_and_cpds", text: "in progress")
        expect(page).to have_css("#employment_history", text: "in progress")
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

        expect(page).to have_css("#personal_details", text: "not started")
        expect(page).to have_css("#professional_status", text: "not started")
        expect(page).to have_css("#qualifications", text: "not started")
        expect(page).to have_css("#training_and_cpds", text: "not started")
        expect(page).to have_css("#employment_history", text: "not started")
      end
    end

    context "when the jobseeker has completed some details in their profile but not all of them" do
      let!(:jobseeker_profile) { create(:jobseeker_profile, :with_qualifications, :with_employment_history, jobseeker: jobseeker, qualified_teacher_status: nil) }

      it "shows all sections that have been filled in with the status tag 'in progress' and shows empty sections with the status tag 'not started'" do
        visit job_path(vacancy)
        within ".banner-buttons" do
          click_on I18n.t("jobseekers.job_applications.banner_links.apply")
        end

        click_button "Start application"

        expect(page).to have_css("#personal_details", text: "not started")
        expect(page).to have_css("#professional_status", text: "not started")
        expect(page).to have_css("#qualifications", text: "in progress")
        expect(page).to have_css("#training_and_cpds", text: "not started")
        expect(page).to have_css("#employment_history", text: "in progress")
      end

      context "when the jobseeker completes a section" do
        it "shows the section as complete", :js do
          visit job_path(vacancy)
          within ".banner-buttons" do
            click_on I18n.t("jobseekers.job_applications.banner_links.apply")
          end

          click_button "Start application"

          within("#personal_details") do
            click_link("Personal details")
          end

          fill_in_personal_details
          click_on "Save and continue"

          expect(page).to have_css("#personal_details", text: "complete")

          within("#professional_status") do
            click_link("Professional status")
          end

          fill_in_professional_status
          click_on "Save and continue"

          expect(page).to have_css("#professional_status", text: "complete")

          within("#qualifications") do
            click_link("Qualifications")
          end

          choose "Yes, I've completed this section"
          click_on "Save and continue"

          expect(page).to have_css("#qualifications", text: "complete")

          within("#training_and_cpds") do
            click_link(I18n.t("jobseekers.job_applications.build.training_and_cpds.heading"))
          end

          choose "Yes, I've completed this section"
          click_on "Save and continue"

          expect(page).to have_css("#training_and_cpds", text: "complete")

          within("#employment_history") do
            click_link(I18n.t("jobseekers.job_applications.build.employment_history.heading"))
          end

          click_on "Add another job"
          fill_in_current_role(start_year: jobseeker_profile.employments.first.ended_on.year.to_s, start_month: jobseeker_profile.employments.first.ended_on.month.to_s)
          click_on "Save role"

          choose "Yes, I've completed this section"
          click_on "Save and continue"

          expect(page).to have_css("#employment_history", text: "complete")
        end
      end
    end
  end
end
