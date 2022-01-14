require "rails_helper"

RSpec.describe "Deadline-passed job applications for jobseekers" do
  context "when an application is in 'draft' status and the deadline for application has passed" do
    let(:deadline) { 1.week.ago }

    let(:vacancy) { create(:vacancy, :with_organisation, :published, expires_at: deadline) }

    let(:jobseeker) { create(:jobseeker) }
    let!(:job_application) do
      create(
        :job_application,
        draft_at: deadline - 1.week,
        jobseeker: jobseeker,
        vacancy: vacancy,
      )
    end

    before do
      login_as(jobseeker, scope: :jobseeker)
    end

    describe "on the 'my applications' page" do
      before do
        visit jobseekers_job_applications_path
        expect(page).to have_css("#applications-results > .card-component", count: 1)
      end

      it "shows a status 'tag' of 'deadline passed'" do
        expect(page).to have_css("#applications-results .govuk-tag", text: "deadline passed")
      end

      it "has a link to view the application" do
        expect(page).to have_link(job_application.vacancy.job_title, href: jobseekers_job_application_review_path(job_application))
      end
    end

    describe "on the application page" do
      before do
        visit jobseekers_job_applications_path
        click_on job_application.vacancy.job_title
      end

      it "has the application status of 'deadline passed'" do
        expect(page).to have_css(".job-application-review-banner .govuk-tag", text: "deadline passed")
      end

      it "does not show the section status indicators" do
        expect(page).not_to have_css(".review-component__section__heading .govuk-tag")
      end

      it "does not allow the jobseeker to edit or update any sections" do
        expect(page).not_to have_css(".review-component__section__heading a")
      end

      it "removes the 'submit application' section" do
        expect(page).not_to have_css(".new_jobseekers_job_application_review_form")
      end
    end
  end
end
