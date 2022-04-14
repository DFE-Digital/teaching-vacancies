require "rails_helper"

RSpec.describe "Submitted job applications for jobseekers" do
  context "when an application is in submitted status" do
    let(:vacancy) { create(:vacancy, :with_organisation, :published) }

    let(:jobseeker) { create(:jobseeker) }
    let!(:job_application) do
      create(
        :job_application,
        :submitted,
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

      it "shows a status 'tag' of 'submitted'" do
        expect(page).to have_css("#applications-results .govuk-tag", text: "submitted")
      end

      it "has a link to view the application" do
        expect(page).to have_link(job_application.vacancy.job_title, href: jobseekers_job_application_path(job_application))
      end
    end

    describe "on the application page" do
      before do
        visit jobseekers_job_applications_path
        click_on job_application.vacancy.job_title
      end

      it "has the application status of 'submitted'" do
        expect(page).to have_css(".review-banner .govuk-tag", text: "submitted")
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
