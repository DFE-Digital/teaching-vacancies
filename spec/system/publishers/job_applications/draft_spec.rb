require "rails_helper"

RSpec.describe "Draft job applications for publishers" do
  context "when an application is in “submitted” status" do
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

    describe "on the “manage jobs“ page" do
      before do
        visit organisation_path
        click_on vacancy.job_title
        click_on "Applications"
        expect(page).to have_css(".card-component", count: 1)
      end

      it "shows a status “tag” of “unread”" do
        expect(page).to have_css(".card-component .govuk-tag", text: "unread")
      end

      it "has a link to view the application" do
        expect(page).to have_link(job_application.name, href: organisation_job_job_application_path(job_application, job_id: vacancy.id))
      end
    end

    describe "on the application page" do
      before do
        visit organisation_path
        click_on vacancy.job_title
        click_on "Applications"
        click_on job_application.name
      end

      it "has the application status of “reviewed”" do
        expect(page).to have_css(".application-status .govuk-tag", text: "reviewed")
      end

      it "does not show the section status indicators" do
        expect(page).not_to have_css(".review-component__section__heading .govuk-tag")
      end

      it "does not allow the jobseeker to edit or update any sections" do
        expect(page).not_to have_css(".review-component__section__heading a")
      end

      it "removes the “submit application” section" do
        expect(page).not_to have_css(".new_jobseekers_job_application_review_form")
      end
    end
  end
end
