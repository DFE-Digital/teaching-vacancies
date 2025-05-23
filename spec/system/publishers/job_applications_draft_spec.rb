require "rails_helper"

RSpec.describe "Draft job applications for publishers" do
  context "when an application is in 'submitted' status" do
    let(:publisher) { create(:publisher, :with_organisation) }

    let(:vacancy) do
      create(:vacancy, :published, publisher: publisher, organisations: publisher.organisations)
    end

    let!(:job_application) do
      create(:job_application, :submitted, vacancy: vacancy)
    end

    before do
      login_publisher(publisher: publisher)
    end

    after { logout }

    describe "on the 'manage jobs' page", :js do
      before do
        visit organisation_job_job_applications_path(vacancy.id)
        expect(page.find(".govuk-table__body")).to have_css(".govuk-table__row", count: 1)
      end

      it "shows a status 'tag' of 'unread'" do
        expect(page).to have_css(".govuk-tag", text: "unread", wait: 5)
      end

      it "has a link to view the application" do
        expect(page).to have_link(job_application.name, href: organisation_job_job_application_path(job_application, job_id: vacancy.id), wait: 5)
      end
    end

    describe "on the application page", :js do
      before do
        visit organisation_job_job_applications_path(vacancy.id)
        click_on job_application.name
      end

      it "has the application status of 'reviewed'" do
        expect(page).to have_css(".application-status.govuk-tag", text: "reviewed", wait: 5)
      end

      it "does not show the section status indicators" do
        expect(page).not_to have_css(".review-component__section__heading .govuk-tag", wait: 5)
      end

      it "does not allow the jobseeker to edit or update any sections" do
        expect(page).not_to have_css(".review-component__section__heading a", wait: 5)
      end

      it "removes the 'submit application' section" do
        expect(page).not_to have_css(".new_jobseekers_job_application_review_form", wait: 5)
      end
    end
  end
end
