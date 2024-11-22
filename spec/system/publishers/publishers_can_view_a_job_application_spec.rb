require "rails_helper"

RSpec.describe "Publishers can view a job application" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    create(:training_and_cpd, job_application: job_application)
  end

  context "when the job application status is withdrawn" do
    let(:job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }

    it "redirects to a page notifying them that the application has been withdrawn" do
      visit organisation_job_job_application_path(vacancy.id, job_application)

      expect(page).to have_current_path(organisation_job_job_application_withdrawn_path(vacancy.id, job_application))
      expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.withdrawn.heading"))
      expect(page).to have_link(I18n.t("publishers.vacancies.job_applications.withdrawn.view_more_applications"), href: organisation_job_job_applications_path(vacancy.id))
    end
  end
end
